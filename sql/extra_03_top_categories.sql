WITH total_filtered AS (
    SELECT SUM(i.price) AS total_revenue
    FROM order_items i
    LEFT JOIN orders o USING(order_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
)

SELECT 
    tr.product_category_name_english AS category, 
    SUM(i.price) AS revenue, 
    COUNT(DISTINCT o.order_id) AS n_orders, 
    (SUM(i.price) / tf.total_revenue) * 100 AS pct_revenue
FROM order_items i
LEFT JOIN orders o USING(order_id)
LEFT JOIN products p USING(product_id)
LEFT JOIN translation tr USING(product_category_name)
CROSS JOIN total_filtered tf
WHERE o.order_purchase_timestamp >= '2017-01-01' 
    AND o.order_purchase_timestamp < '2018-09-01'
    AND o.order_status NOT IN ('canceled', 'unavailable')
    AND i.price IS NOT NULL
GROUP BY tr.product_category_name_english, tf.total_revenue
ORDER BY revenue DESC
LIMIT 10;