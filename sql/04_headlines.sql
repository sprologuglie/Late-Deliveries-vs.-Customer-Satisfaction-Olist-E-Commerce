WITH latest_month AS (
    SELECT 
        date_trunc('month', o.order_purchase_timestamp) AS month,
        AVG(is_late::INT) * 100 AS perc_late_orders
    FROM v_delivery
    LEFT JOIN orders o USING(order_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    GROUP BY month
    HAVING COUNT(DISTINCT order_id) > 30
    ORDER BY perc_late_orders DESC
    LIMIT 3
),
base_data AS (
    SELECT 
        CASE 
            WHEN NOT is_late THEN '0 - In orario'
            WHEN is_late AND days_late <= 3 THEN '1 - ritardo 1-3gg'
            WHEN days_late > 3 AND days_late <= 7 THEN '2 - ritardo 4-7gg'
            ELSE '3 - ritardo 8+gg' END AS bucket,
        r.review_score AS score,
        COUNT(*) AS cnt
    FROM v_delivery
    LEFT JOIN v_reviews r USING(order_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
        AND review_score IS NOT NULL
    GROUP BY 1, 2 
)

SELECT 
    'A) perc_late_orders' AS metric_name,
    ROUND(SUM(is_late::INT)::NUMERIC / COUNT(*) * 100, 2)::TEXT AS metric_value
FROM v_delivery
LEFT JOIN orders o USING(order_id)
WHERE order_id IN (SELECT order_id FROM v_orders_scope)

UNION ALL

SELECT 
    'B) months with most late orders' AS metric_name,
    month AS metric_value
FROM latest_month

UNION ALL

SELECT 
    CASE WHEN NOT is_late THEN 'C) On time avg score'
        WHEN days_late > 7 THEN 'C) 8+ days late avg score' 
    END AS metric_name,
    ROUND(AVG(r.review_score), 2) AS metric_value
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    AND review_score IS NOT NULL
    AND (NOT is_late OR days_late > 7)
GROUP BY 1

UNION ALL

SELECT 
    'D) pct score 1 for 8+ days late' AS metric_name,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*) 
            FROM v_delivery d2 
            LEFT JOIN v_reviews r2 USING(order_id)
            WHERE d2.order_id IN (SELECT order_id FROM v_orders_scope)
              AND d2.days_late > 7 
              AND r2.review_score IS NOT NULL
        ), 2
    )::TEXT AS metric_value
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    AND days_late > 7
    AND review_score = 1

UNION ALL

SELECT 
    state_name AS metric_name,
    metric_value AS metric_value
FROM (
    SELECT 
        'E) states_with_most_late_orders - ' || customer_state AS state_name, 
        ROUND((AVG(is_late::INT) * 100)::NUMERIC, 2)::TEXT AS metric_value
    FROM v_delivery
    LEFT JOIN orders o USING(order_id)
    LEFT JOIN v_reviews r USING(order_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    GROUP BY customer_state
    HAVING COUNT(DISTINCT order_id) > 30
    ORDER BY AVG(is_late::INT) DESC
    LIMIT 3
) AS top_late_states

UNION ALL

SELECT 
    state_name AS metric_name,
    metric_value AS metric_value
FROM (
    SELECT 
        'F) states_with_lowest_avg_score - ' || customer_state AS state_name,
        ROUND(AVG(review_score)::NUMERIC, 2)::TEXT AS metric_value
    FROM v_delivery
    LEFT JOIN orders o USING(order_id)
    LEFT JOIN v_reviews r USING(order_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    GROUP BY customer_state
    HAVING COUNT(DISTINCT order_id) > 30
    ORDER BY AVG(review_score) ASC 
    LIMIT 3
) AS lowest_score_states

UNION ALL

SELECT 'G) perc_late_orders_of_top_50_latest_sellers (~11%)',
    ROUND(SUM(late_orders) / 
        ( SELECT COUNT(*)
            FROM v_delivery
            WHERE order_id IN (SELECT order_id FROM v_orders_scope)
                AND is_late = 1
        )
     * 100, 2)
FROM (
SELECT 
        s.seller_id AS seller,
        SUM(is_late::INT) AS late_orders
    FROM v_delivery
    LEFT JOIN order_items i USING(order_id)
    LEFT JOIN sellers s USING(seller_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    GROUP BY s.seller_id
    HAVING COUNT(DISTINCT order_id) > 30
    ORDER BY 2 DESC
    LIMIT 50
) AS sellers_stats