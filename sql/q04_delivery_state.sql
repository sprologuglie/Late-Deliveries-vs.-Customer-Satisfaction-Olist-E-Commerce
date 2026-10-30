SELECT 
    s.seller_state, 
    AVG(is_late::INT) * 100 AS perc_late_orders,
    QUANTILE_CONT(days_actual, 0.5) AS median_days_delivery,
    QUANTILE_CONT(days_actual, 0.9) AS p90_days_delivery,
    QUANTILE_CONT(days_late, 0.5) AS median_days_late, 
    QUANTILE_CONT(days_late, 0.9) AS p90_days_late,
    COUNT(DISTINCT i.order_id) AS n_orders,
    SUM(is_late::INT) AS n_late_orders
FROM v_delivery
LEFT JOIN order_items i USING(order_id)
LEFT JOIN sellers s USING(seller_id)
LEFT JOIN orders o USING(order_id)
WHERE o.order_purchase_timestamp >= '2017-01-01'  -- Stessi filtri di q2
        AND o.order_purchase_timestamp < '2018-09-01'
        AND o.order_status NOT IN ('canceled', 'unavailable')
        AND i.price IS NOT NULL
GROUP BY s.seller_state
HAVING COUNT(DISTINCT i.order_id) > 30
ORDER BY perc_late_orders DESC