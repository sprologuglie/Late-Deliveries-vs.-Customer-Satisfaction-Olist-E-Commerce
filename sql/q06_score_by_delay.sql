SELECT 
    CASE WHEN NOT is_late THEN '0 - In orario'
        WHEN is_late AND days_late <= 3 THEN '1 - ritardo 1-3gg'
        WHEN days_late > 3 AND days_late <= 7 THEN '2 - ritardo 4-7gg'
        ELSE '3 - ritardo 8+gg' END AS bucket,
    COUNT(*) AS n,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
LEFT JOIN order_items i USING(order_id)
LEFT JOIN sellers s USING(seller_id)
LEFT JOIN orders o USING(order_id)
WHERE o.order_purchase_timestamp >= '2017-01-01'  -- Stessi filtri di q2
        AND o.order_purchase_timestamp < '2018-09-01'
        AND o.order_status NOT IN ('canceled', 'unavailable')
        AND i.price IS NOT NULL
GROUP BY bucket
HAVING COUNT(DISTINCT i.order_id) > 30
ORDER BY bucket;