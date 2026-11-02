SELECT 
    customer_state AS state, 
    AVG(is_late::INT) * 100 AS perc_late_orders,
    AVG(review_score) AS avg_score,
    COUNT(DISTINCT order_id) AS n_orders,
    SUM(is_late::INT) AS n_late_orders,
    QUANTILE_CONT(days_actual, 0.5) AS median_days_delivery,
    QUANTILE_CONT(days_actual, 0.9) AS p90_days_delivery,
    QUANTILE_CONT(CASE WHEN days_late <= 0 THEN NULL 
                    ELSE days_late END, 0.5) AS median_days_late, 
    QUANTILE_CONT(CASE WHEN days_late <= 0 THEN NULL 
                    ELSE days_late END, 0.9) AS p90_days_late
FROM v_delivery
LEFT JOIN orders o USING(order_id)
LEFT JOIN v_reviews r USING(order_id)
WHERE order_id IN (SELECT order_id FROM v_orders_scope)
GROUP BY customer_state
HAVING COUNT(DISTINCT order_id) > 30
ORDER BY perc_late_orders DESC