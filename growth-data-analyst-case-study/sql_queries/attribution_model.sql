-- CTE to get all order data starting from January 2023
WITH order_events AS (
  SELECT
    shopifyOrderId,
    TIMESTAMP_MILLIS(CAST(timestamp AS INT64)) AS order_timestamp,
    shopifyOrderProcessedAt AS order_datetime,
    shopifyOrderTotalPrice AS order_total,
    FORMAT_DATE('%Y-%m', DATE(shopifyOrderProcessedAt)) AS order_month,
    ip,
    ROW_NUMBER() OVER(PARTITION BY shopifyOrderId ORDER BY timestamp) AS row_num
  FROM `polar-455513.growth.pixeldata`
  WHERE 
    shopifyOrderId IS NOT NULL
    AND pagePath LIKE '%/thank_you'
    AND DATE(shopifyOrderProcessedAt) >= '2023-01-01'
  QUALIFY ROW_NUMBER() OVER(PARTITION BY shopifyOrderId ORDER BY TIMESTAMP_MILLIS(CAST(timestamp AS INT64))) = 1

),

-- CTE to find every interactions that happened within 30 days before each purchase
pre_purchase_events AS (
  SELECT
    o.shopifyOrderId,
    o.order_timestamp,
    o.order_datetime,
    o.order_total,
    o.order_month,
    o.ip,
    p.timestamp AS event_timestamp,
    TIMESTAMP_MILLIS(CAST(p.timestamp AS INT64)) AS event_timestamp_formatted,
    p.sessionId,
    COALESCE(p.utmSource, 
      CASE 
        WHEN p.pageReferrer IS NULL OR p.pageReferrer = '' OR p.pageReferrer LIKE '%almondcow.co%' THEN 'direct'
        ELSE REGEXP_EXTRACT(REGEXP_EXTRACT(p.pageReferrer, 'http[s]?://([^/]*)'), '([^.]+\\.[^.]+)$') 
      END) AS source
  FROM order_events o
  JOIN `polar-455513.growth.pixeldata` p
    ON o.ip = p.ip
    AND TIMESTAMP_MILLIS(CAST(p.timestamp AS INT64)) <= o.order_timestamp
    AND TIMESTAMP_MILLIS(CAST(p.timestamp AS INT64)) >= TIMESTAMP_SUB(o.order_timestamp, INTERVAL 30 DAY)
),

-- CTE to implement session logic 
with_prev_timestamp AS (
  SELECT
    *,
    LAG(event_timestamp_formatted) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS prev_timestamp
  FROM pre_purchase_events
),

-- CTE to mark session boundaries
session_boundaries AS (
  SELECT
    *,
    CASE 
      WHEN prev_timestamp IS NULL OR 
           TIMESTAMP_DIFF(event_timestamp_formatted, prev_timestamp, SECOND) > 1800 
      THEN 1 
      ELSE 0 
    END AS is_new_session
  FROM with_prev_timestamp
),

-- CTE to assgn session number
session_groups AS (
  SELECT
    *,
    SUM(is_new_session) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS session_number
  FROM session_boundaries
),

-- CTE to identify entry source (first touchpoint) and session start
session_sources AS (
  SELECT
    shopifyOrderId,
    order_total,
    order_month,
    ip,
    session_number,
    ARRAY_AGG(source ORDER BY event_timestamp ASC LIMIT 1)[OFFSET(0)] AS session_source,
    MIN(event_timestamp_formatted) AS session_start
  FROM session_groups
  GROUP BY shopifyOrderId, order_total, order_month, ip, session_number
),

-- CTEs to identify first-touch source for each order
first_touch_sources AS (
  SELECT
    shopifyOrderId,
    MIN(session_start) AS min_start_time
  FROM session_sources
  GROUP BY shopifyOrderId
),

first_touch AS (
  SELECT
    s.shopifyOrderId,
    s.session_source AS first_touch_source
  FROM session_sources s
  INNER JOIN first_touch_sources f 
    ON s.shopifyOrderId = f.shopifyOrderId 
    AND s.session_start = f.min_start_time
),

-- CTEs to identify last-touch source for each order
last_touch_sources AS (
  SELECT
    shopifyOrderId,
    MAX(session_start) AS max_start_time
  FROM session_sources
  GROUP BY shopifyOrderId
),

last_touch AS (
  SELECT
    s.shopifyOrderId,
    s.session_source AS last_touch_source
  FROM session_sources s
  INNER JOIN last_touch_sources l 
    ON s.shopifyOrderId = l.shopifyOrderId 
    AND s.session_start = l.max_start_time
),

-- CTE to caculate how many sessions for each purchase
session_counts AS (
  SELECT
    shopifyOrderId,
    COUNT(*) AS session_count
  FROM session_sources
  GROUP BY shopifyOrderId
),

-- CTE to implement the U-shaped attribution model with a 40-20-40 weighting scheme
session_attribution_raw AS (
  SELECT
    s.shopifyOrderId,
    s.order_total,
    s.order_month,
    s.session_number,
    s.session_source,
    c.session_count,
    f.first_touch_source,
    l.last_touch_source,
    CASE
      WHEN c.session_count = 1 THEN 1.0  -- 100% to single source
      WHEN s.session_source = f.first_touch_source AND s.session_source = l.last_touch_source THEN 
        CASE 
          WHEN c.session_count = 1 THEN 1.0  -- It's both first and last because it's the only touchpoint
          ELSE 0.8  -- It gets both the first-touch (0.4) and last-touch (0.4) weights
        END
      WHEN s.session_source = f.first_touch_source THEN 0.4  -- 40% to first touch
      WHEN s.session_source = l.last_touch_source THEN 0.4  -- 40% to last touch
      ELSE 
        CASE
          WHEN c.session_count > 2 THEN 0.2 / (c.session_count - 2)  -- Distribute 20% evenly across middle touchpoints
          ELSE 0  -- No middle touchpoints in a 2-session journey
        END
    END AS attribution_weight
  FROM session_sources s
  JOIN session_counts c ON s.shopifyOrderId = c.shopifyOrderId
  JOIN first_touch f ON s.shopifyOrderId = f.shopifyOrderId
  JOIN last_touch l ON s.shopifyOrderId = l.shopifyOrderId
),

-- CTE to implement a normalization step to ensure attribution weights for each order sum to 1
session_attribution AS (
  SELECT
    *,
    attribution_weight / NULLIF(SUM(attribution_weight) OVER (PARTITION BY shopifyOrderId), 0) AS normalized_weight
  FROM session_attribution_raw
)

-- CTE to calculate the total attributed revenue by source
total_source_attribution AS (
  SELECT
    session_source AS source,
    ROUND(SUM(normalized_weight * order_total), 2) AS attributed_revenue
  FROM session_attribution
  GROUP BY session_source
)

-- CTE to rank sources by total attributed revenue
ranked_sources AS (
  SELECT
    source,
    attributed_revenue,
    ROW_NUMBER() OVER (ORDER BY attributed_revenue DESC) AS revenue_rank
  FROM total_source_attribution
)

-- Final output with top 9 and others grouped
SELECT 
  CASE 
    WHEN revenue_rank <= 9 THEN source
    ELSE '10+ others'
  END AS source_group,
  SUM(attributed_revenue) AS attributed_revenue
FROM ranked_sources
GROUP BY 
  CASE 
    WHEN revenue_rank <= 9 THEN source
    ELSE '10+ others'
  END
ORDER BY 
  CASE WHEN source_group = '10+ others' THEN 0 ELSE attributed_revenue END DESC