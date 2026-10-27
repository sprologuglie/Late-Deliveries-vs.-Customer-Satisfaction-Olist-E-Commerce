-- Top 10 categories per revenue
SELECT t.product_category_name_english AS category, SUM(price) AS total_revenue
FROM order_items i
LEFT JOIN products p USING (product_id)
LEFT JOIN translation t USING (product_category_name)
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10