-- Top 10 categories by revenue (SUM(price)), item grain, same scope as the other queries.
-- Untranslated categories keep the Portuguese name; NULL categories are 'unknown'.
WITH scoped_items AS (
    SELECT
        i.order_id,
        i.price,
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
    FROM order_items i
    JOIN v_orders_scope s USING (order_id)
    LEFT JOIN products p USING (product_id)
    LEFT JOIN translation t USING (product_category_name)
    WHERE i.price IS NOT NULL
)
SELECT
    category,
    SUM(price) AS revenue,
    COUNT(DISTINCT order_id) AS n_orders,
    100.0 * SUM(price) / SUM(SUM(price)) OVER () AS pct_revenue   -- share of total revenue, not of the top 10
FROM scoped_items
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;
