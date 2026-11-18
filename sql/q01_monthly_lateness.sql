-- Late rate and delivery times per purchase month (minimum 30 orders per month)
SELECT
    date_trunc('month', s.order_purchase_timestamp) AS month,
    AVG(d.is_late::INT) * 100 AS perc_late_orders,
    QUANTILE_CONT(d.days_actual, 0.5) AS median_days_delivery,
    QUANTILE_CONT(d.days_actual, 0.9) AS p90_days_delivery,
    QUANTILE_CONT(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END, 0.5) AS median_days_late,
    QUANTILE_CONT(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END, 0.9) AS p90_days_late,
    COUNT(*) AS n_orders,
    SUM(d.is_late::INT) AS n_late_orders
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
GROUP BY month
HAVING COUNT(*) >= 30
ORDER BY month;
