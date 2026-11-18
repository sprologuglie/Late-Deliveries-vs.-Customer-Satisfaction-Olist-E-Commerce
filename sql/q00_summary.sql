-- Scope summary: delivered orders with at least one item
WITH base AS (
SELECT d.order_id,
        d.is_late,
        r.review_score
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
LEFT JOIN v_reviews r USING (order_id)
WHERE EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = d.order_id)
)
SELECT COUNT(*)                                         AS n_orders,
        COUNT(review_score)                             AS n_with_review,
        ROUND(100 * COUNT(review_score) / COUNT(*), 1)  AS pct_with_review,
        ROUND(100 * AVG(is_late::INT), 2)               AS pct_late,
        ROUND(AVG(review_score), 3)                     AS avg_score
FROM base;
