-- Late rate, review score and delivery times per customer state (minimum 30 orders per state)
SELECT
    d.customer_state AS state,
    AVG(d.is_late::INT) * 100 AS perc_late_orders,
    AVG(r.review_score) AS avg_score,
    COUNT(*) AS n_orders,
    SUM(d.is_late::INT) AS n_late_orders,
    QUANTILE_CONT(d.days_actual, 0.5) AS median_days_delivery,
    QUANTILE_CONT(d.days_actual, 0.9) AS p90_days_delivery,
    QUANTILE_CONT(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END, 0.5) AS median_days_late,
    QUANTILE_CONT(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END, 0.9) AS p90_days_late
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
LEFT JOIN v_reviews r USING (order_id)
GROUP BY d.customer_state
HAVING COUNT(*) >= 30
ORDER BY perc_late_orders DESC;
