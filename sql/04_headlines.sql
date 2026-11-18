-- Headline metrics for the README, all computed on the analysis scope
-- (delivered orders in v_orders_scope; reviews = latest per order). One row per metric.
-- Minimum sample for ranked groups (months, states): 30 orders.
WITH base AS (
    SELECT d.order_id,
           d.customer_state,
           d.is_late,
           d.days_late,
           date_trunc('month', s.order_purchase_timestamp) AS month,
           r.review_score
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    LEFT JOIN v_reviews r USING (order_id)
),
monthly AS (
    SELECT month, AVG(is_late::INT) * 100 AS pct_late
    FROM base
    GROUP BY month
    HAVING COUNT(*) >= 30
),
worst_months AS (
    SELECT month, pct_late, ROW_NUMBER() OVER (ORDER BY pct_late DESC) AS rk
    FROM monthly
    QUALIFY rk <= 3
),
state_stats AS (
    SELECT customer_state,
           AVG(is_late::INT) * 100 AS pct_late,
           AVG(review_score) AS avg_score
    FROM base
    GROUP BY customer_state
    HAVING COUNT(*) >= 30
),
late_states AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY pct_late DESC) AS rk
    FROM state_stats
    QUALIFY rk <= 3
),
low_score_states AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY avg_score ASC) AS rk
    FROM state_stats
    QUALIFY rk <= 3
),
-- seller grain: (order, seller), see v_order_sellers
seller_stats AS (
    SELECT os.seller_id, SUM(b.is_late::INT) AS late_orders
    FROM base b
    JOIN v_order_sellers os USING (order_id)
    GROUP BY os.seller_id
),
top_sellers AS (
    SELECT * FROM seller_stats ORDER BY late_orders DESC, seller_id LIMIT 50
)

SELECT 'A) % late orders' AS metric_name,
       ROUND(AVG(is_late::INT) * 100, 2)::VARCHAR AS metric_value
FROM base

UNION ALL

SELECT 'B) month with highest late rate #' || rk,
       strftime(month, '%Y-%m') || ' (' || ROUND(pct_late, 2) || '%)'
FROM worst_months

UNION ALL

SELECT 'C) avg score, on time', ROUND(AVG(review_score), 2)::VARCHAR
FROM base
WHERE NOT is_late

UNION ALL

SELECT 'C) avg score, 8+ days late', ROUND(AVG(review_score), 2)::VARCHAR
FROM base
WHERE days_late > 7

UNION ALL

SELECT 'D) % of reviews with score 1, 8+ days late',
       ROUND(100.0 * COUNT(*) FILTER (WHERE review_score = 1) / COUNT(review_score), 2)::VARCHAR
FROM base
WHERE days_late > 7

UNION ALL

SELECT 'D) % of reviews with score 1-2, 8+ days late',
       ROUND(100.0 * COUNT(*) FILTER (WHERE review_score <= 2) / COUNT(review_score), 2)::VARCHAR
FROM base
WHERE days_late > 7

UNION ALL

SELECT 'E) state with highest late rate #' || rk || ' - ' || customer_state,
       ROUND(pct_late, 2)::VARCHAR
FROM late_states

UNION ALL

SELECT 'F) state with lowest avg score #' || rk || ' - ' || customer_state,
       ROUND(avg_score, 2)::VARCHAR
FROM low_score_states

UNION ALL

-- share of late (order, seller) pairs that belong to the 50 sellers with most late orders
SELECT 'G) % of late orders from the 50 sellers with most late orders',
       ROUND(100.0 * (SELECT SUM(late_orders) FROM top_sellers) / (SELECT SUM(late_orders) FROM seller_stats), 2)::VARCHAR

ORDER BY metric_name;
