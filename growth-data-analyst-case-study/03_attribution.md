# Ecommerce Attribution
I first cleaned the CSV file using Python and converted it into a JSONL file for the following exercises. (Thank you, Sonnet 3.7.) Then, I uploaded the file to a GCP bucket before creating a dataset in BigQuery.

# Number of orders per month per store
![Monthly orders](images/monthly_orders.png)

## Key Findings
- Strong seasonal pattern with peak revenue during Nov-Dec 2022 holiday season (BFCM + Christmas)
- Significant drop in Jan 2023 showing typical post-holiday slump
- AOV highest during Nov-Dec ($251) and dropped to ~$205 in Jan-Feb as customers were likely more price-sensitive
- Gradual recovery in both order volume and AOV through Spring 2023

## SQL Query used to calculate the number of orders per month per store

```sql
WITH orders AS (
  SELECT 
    REGEXP_REPLACE(shopifyShopURL, '^https?://|/$', '') AS store,
    shopifyOrderId AS order_id,
    DATE(shopifyOrderProcessedAt) AS order_date,
    FORMAT_DATE('%b %Y', DATE(shopifyOrderProcessedAt)) as order_month,
    shopifyOrderTotalPrice AS order_total,
    ROW_NUMBER() OVER(PARTITION BY shopifyOrderId ORDER BY shopifyOrderProcessedAt) AS row_num
  FROM growth.pixeldata
  WHERE shopifyOrderId IS NOT NULL
    AND pagePath LIKE '%/thank_you'
),

monthly_orders AS (
  SELECT
    store,
    order_month,
    COUNT(*) AS order_count,
    ROUND(SUM(order_total), 2) AS total_revenue,
    ROUND(SUM(order_total) / COUNT(*), 2) AS avg_order_value
  FROM orders
  WHERE row_num = 1
  GROUP BY store, order_month
  ORDER BY store, PARSE_DATE('%b %Y', order_month)
)

SELECT * FROM monthly_orders

```

This query addresses several important data quality considerations:

1. Normalizes store URLs to ensure consistent grouping regardless of URL format
2. Filters for actual conversion events using the `thank_you` page path, avoiding duplicate counting from order status checks
3. Deduplicates multiple pixel events for the same order ID by using `ROW_NUMBER()` and selecting only the first occurrence
4. Takes the earliest order record when multiple events exist, ensuring consistent handling of duplicates
5. Calculates key metrics like order count, total revenue, and average order value


# Attribution Modelling

Before choosing an attribution model, let's analyze how many touchpoints customers have within a 30-day window before purchasing.

I hypothesise that with an AOV over $225, Almond Cow's customers visit the store multiple times before committing to purchase, as this represents a considered decision rather than an impulse buy.

After analyzing the data for orders placed from January 2023 onward (ensuring complete 30-day lookback data), the results confirmed my hypothesis:
![Touchpoints](images/touchpoints.png)

As we can see in the above chart, nearly half of all customers interact with the brand through multiple sessions before purchasing.

This multi-touch behavior makes sense for a premium product like a milk maker, where customers likely research recipes, explore features, and consider their options across multiple visits.

## SQL Query used to find how many touchpoints customers have

First, I wrote a CTE to get all order data, filtering only for "thank you" pages and orders from January 2023 onwards. I'm using a 30-day lookback window, and the first events in the dataset were triggered around November 24th, so starting from January gives us complete lookback data for all orders.

I also used the `ROW_NUMBER()` function to handle potential duplicate order events by assigning a sequence number to each order record:


```sql
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
)
```

Next, I joined the unique orders with all the pixel data to find every interaction that happened within 30 days before each purchase. I'm using the IP address to connect users to their events and adding logic to determine the traffic source:

```sql
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
```

This is where I implemented the session logic. I first used a `LAG()` function to find the previous timestamp for each event:

```sql
with_prev_timestamp AS (
  SELECT
    *,
    LAG(event_timestamp_formatted) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS prev_timestamp
  FROM pre_purchase_events
),
```

Then I marked session boundaries when there's a gap of more than 30 minutes between events:

```sql
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
```

I then used a cumulative sum to assign a consistent session number to all events in the same session:
```sql
session_groups AS (
  SELECT
    *,
    SUM(is_new_session) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS session_number
  FROM session_boundaries
),
```

For each session, I identified the entry source (first touchpoint), session duration, and interaction count:
```sql
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
)
```

I then counted sessions per order and constructed the customer journey path:
```sql
session_counts_per_order AS (
  SELECT
    shopifyOrderId,
    COUNT(*) AS session_count,
    STRING_AGG(session_source, ' > ' ORDER BY session_start) AS source_path
  FROM session_sources
  GROUP BY shopifyOrderId
)
```

Finally, I created a distribution to see how many touchpoints customers typically have before purchasing:
```sql
session_distribution AS (
  SELECT
    CASE WHEN session_count >= 5 THEN '5+' ELSE CAST(session_count AS STRING) END AS session_count_group,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
  FROM session_counts_per_order
  GROUP BY session_count_group
)
```

## Attribution Model Selection: U-shaped
Based on these findings, I've decided to implement a position-based (U-shaped) attribution model, which:
- Gives 40% credit to the first touchpoint (discovery)
- Gives 40% credit to the last touchpoint (conversion)
- Distributes the remaining 20% across middle touchpoints

This model recognizes both the critical discovery phase and the final conversion decision, while acknowledging the nurturing effect of middle interactions. For single-session journeys, the source receives 100% of the credit.

![Attribution U-shaped](images/attribution.png)

| Source Group | Attributed Revenue | Percentage Total |
|-------------|-------------------|-----------------|
| direct | $2,189,379 | 56% |
| google.com | $409,968 | 10% |
| google | $307,695 | 8% |
| attentive | $188,450 | 5% |
| facebook | $160,776 | 4% |
| Almond Cow Customers Subscribers | $140,253 | 4% |
| instagram+only | $120,683 | 3% |
| instagram.com | $92,580 | 2% |
| facebook.com | $47,411 | 1% |
| Others | $284,944 | 7% |
| - | $3,942,139 | 100% |

Direct traffic is the dominant channel, accounting for over $2,189,379 in attributed revenue, which is more than 5 times higher than the next largest source.


The top channels in order are:
- Direct traffic ($2,189,379 ) - This represents users who directly visited the site without an identifiable referring source
G- oogle.com ($409,968 ) - Organic search traffic from Google
- Google ($307,695 ) - Paid Google campaigns with proper UTM tagging
- Attentive ($188,450 ) - SMS marketing campaigns
- Facebook ($188,450 ) - paid Facebook campaigns with UTM tagging
- Almond Cow Customers & Subscribers ($188,450 ) - Specific Email marketing campaigns
- Instagram only ($188,450 ) - Specific Instagram campaigns
- Instagram.com ($188,450 ) - Organic Instagram traffic
- Facebook.com ($188,450 ) - Organic Facebook traffic
- Others ($188,450 ) - All remaining smaller sources


### SQL Query used to build the attribution model

First, I wrote a CTE to get all order data, filtering only for "thank you" pages and orders from January 2023 onwards. I'm using a 30-day lookback window, and the first events in the dataset were triggered around November 24th, so starting from January gives us complete lookback data for all orders.

I also used the `ROW_NUMBER()` function to handle potential duplicate order events by assigning a sequence number to each order record:


```sql
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

)
```

Next, I joined the unique orders with all the pixel data to find every interaction that happened within 30 days before each purchase. I'm using the IP address to connect users to their events and adding logic to determine the traffic source:

```sql
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
)
```

This is where I implemented the session logic. I first used a `LAG()` function to find the previous timestamp for each event:

```sql
with_prev_timestamp AS (
  SELECT
    *,
    LAG(event_timestamp_formatted) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS prev_timestamp
  FROM pre_purchase_events
),
```

Then I marked session boundaries when there's a gap of more than 30 minutes between events:

```sql
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
```

I then used a cumulative sum to assign a consistent session number to all events in the same session:
```sql
session_groups AS (
  SELECT
    *,
    SUM(is_new_session) OVER(PARTITION BY shopifyOrderId, ip ORDER BY event_timestamp) AS session_number
  FROM session_boundaries
),
```

For each session, I identified the entry source (first touchpoint) and session start:
```sql
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
)
```

I identified the first-touch source for each order by finding the earliest session associated with that order:

```sql
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
)
```

Similarly, I identified the last-touch source for each order by finding the most recent session before purchase.
```sql
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
)
```

Then I calculated how many sessions each user had before making a purchase, which is important for properly distributing attribution weights.
```sql
session_counts AS (
  SELECT
    shopifyOrderId,
    COUNT(*) AS session_count
  FROM session_sources
  GROUP BY shopifyOrderId
)
```

Here I implemented the position-based attribution model with a 40-20-40 weighting scheme. I had to handle various edge cases, including single-session journeys and cases where the same source appears as both first and last touch.

```sql
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
)
```

Then I added a normalization step to ensure that attribution weights for each order sum to exactly 1.0, which ensures that we're attributing the correct amount of revenue.
```sql
session_attribution AS (
  SELECT
    *,
    attribution_weight / NULLIF(SUM(attribution_weight) OVER (PARTITION BY shopifyOrderId), 0) AS normalized_weight
  FROM session_attribution_raw
)

I calculated the total attributed revenue by source by summing the weighted revenue across all orders:
```sql
total_source_attribution AS (
  SELECT
    session_source AS source,
    ROUND(SUM(normalized_weight * order_total), 2) AS attributed_revenue
  FROM session_attribution
  GROUP BY session_source
)
```

And finally, I ranked the sources by total attributed revenue, keeping the top 9 sources individually and grouping all remaining smaller sources into a "10+ others" category for clarity.
```sql
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
```

### Validation Methods
As seen in the table below, attributed revenue of $3,942,139 matches actual total revenue of $3,942,384 from the events dataset:

| Metric | Amount |
|--------|--------|
| Total Revenue | $3,942,384 |
| Attributed Revenue | $3,942,139 |

The small difference is due to floating-point precision, not a methodological issue.

### Technical Notes
- The `sessionId` field in the data wasn't reliable (multiple session IDs could appear within what should logically be considered the same session), so I created my own session boundaries based on time gaps
- Used a 30-minute inactivity threshold to define session boundaries, which is an industry standard approach
- Implemented a fallback hierarchy for events without UTM parameters:
  1. Used `pageReferrer` to identify the source domain
  2. Classified traffic from Almond Cow's own domain as `direct`
  3. For external referrers, extracted the domain using REGEXP function (Thanks BigQuery)
- Applied a normalization step to ensure attribution weights sum to exactly 1.0 for each order
- The reliance on IP address for user identification makes it impossible to track users who switch networks or devices.

Also, 56% of the revenues are attributed to the `direct` traffic, which may indicate an inconsistent implementation of UTM parameters across marketing campaigns.