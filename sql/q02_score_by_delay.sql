-- Average review score per delay bucket (bucket definition: v_delivery.delay_bucket)
SELECT
    d.delay_bucket AS bucket,
    COUNT(*) AS n,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
JOIN v_reviews r USING (order_id)
WHERE r.review_score IS NOT NULL
GROUP BY bucket
ORDER BY bucket;
