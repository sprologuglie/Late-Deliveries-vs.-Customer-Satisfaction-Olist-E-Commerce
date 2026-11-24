-- Sensitivity check: ~5% of the reviews in scope were answered before the recorded delivery date
-- (check S in 05_extra_checks.sql). Average score by delay bucket, split by whether the review
-- was answered before or after the recorded delivery.
SELECT
    d.delay_bucket AS bucket,
    (r.review_answer_timestamp < o.order_delivered_customer_date) AS answered_before_delivery,
    COUNT(*) AS n,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
JOIN v_reviews r USING (order_id)
JOIN orders o USING (order_id)
WHERE r.review_score IS NOT NULL
GROUP BY bucket, answered_before_delivery
ORDER BY bucket, answered_before_delivery;
