-- Is the score drop a product-category artifact?
-- Grain: (order, category). An order with items in several categories counts once in each
-- (see check L in 03_quality_checks.sql). Only reviewed orders are used.
-- Categories without English translation keep the Portuguese name; NULL categories are 'unknown'.
-- Only categories with at least 30 reviewed orders in BOTH groups (on time, 8+ days late) are returned.
WITH order_category AS (
    SELECT DISTINCT
        i.order_id,
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
    FROM order_items i
    LEFT JOIN products p USING (product_id)
    LEFT JOIN translation t USING (product_category_name)
),
base AS (
    SELECT oc.category, d.is_late, d.days_late, r.review_score
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    JOIN v_reviews r USING (order_id)
    JOIN order_category oc USING (order_id)
    WHERE r.review_score IS NOT NULL
)
SELECT
    category,
    COUNT(*) FILTER (WHERE NOT is_late) AS n_on_time,
    COUNT(*) FILTER (WHERE days_late > 7) AS n_8_plus_days_late,
    ROUND(AVG(review_score) FILTER (WHERE NOT is_late), 2) AS avg_score_on_time,
    ROUND(AVG(review_score) FILTER (WHERE days_late > 7), 2) AS avg_score_8_plus_days_late
FROM base
GROUP BY category
HAVING COUNT(*) FILTER (WHERE NOT is_late) >= 30
   AND COUNT(*) FILTER (WHERE days_late > 7) >= 30;
