-- CTE to get all unique order data starting from January 2023
WITH order_events AS (
  SELECT
    shopifyOrderId,
    TIMESTAMP_MILLIS(CAST(timestamp AS INT64)) AS order_timestamp,
    DATE(shopifyOrderProcessedAt) AS order_datetime,
    shopifyOrderTotalPrice AS order_total,
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
    o.ip,
    p.timestamp AS event_timestamp,
    TIMESTAMP_MILLIS(CAST(p.timestamp AS INT64)) AS event_timestamp_formatted,
    p.pagePath,
    p.utmSource,
    p.pageReferrer,
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

-- CTE to identify first touchpoint, session duration and interaction count
session_sources AS (
  SELECT
    shopifyOrderId,
    ip,
    session_number,
    ARRAY_AGG(source ORDER BY event_timestamp ASC LIMIT 1)[OFFSET(0)] AS session_source,
    MIN(event_timestamp_formatted) AS session_start,
    MAX(event_timestamp_formatted) AS session_end,
    COUNT(*) AS interactions_in_session
  FROM session_groups
  GROUP BY shopifyOrderId, ip, session_number
),

-- CTE to count sessions per order
session_counts_per_order AS (
  SELECT
    shopifyOrderId,
    COUNT(*) AS session_count,
    STRING_AGG(session_source, ' > ' ORDER BY session_start) AS source_path
  FROM session_sources
  GROUP BY shopifyOrderId
),

-- final CTE to see session distribution
session_distribution AS (
  SELECT
    CASE WHEN session_count >= 5 THEN '5+' ELSE CAST(session_count AS STRING) END AS session_count_group,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
  FROM session_counts_per_order
  GROUP BY session_count_group
)