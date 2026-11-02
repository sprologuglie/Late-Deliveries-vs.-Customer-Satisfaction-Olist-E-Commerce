SELECT 
    CASE WHEN NOT is_late THEN '0 - In orario'
        WHEN is_late AND days_late <= 3 THEN '1 - ritardo 1-3gg'
        WHEN days_late > 3 AND days_late <= 7 THEN '2 - ritardo 4-7gg'
        ELSE '3 - ritardo 8+gg' END AS bucket,
    COUNT(*) AS n,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    AND review_score IS NOT NULL
GROUP BY bucket
ORDER BY bucket;