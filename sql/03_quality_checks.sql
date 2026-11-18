WITH checks AS (
    SELECT 'A) orders without items' AS check_name, COUNT(*)::VARCHAR AS metric_value
    FROM orders o
    WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)

    UNION ALL

    SELECT 'B) items without order', COUNT(*)::VARCHAR
    FROM order_items
    WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.order_id = order_items.order_id)

    UNION ALL

    SELECT 'C) orders with > 1 reviews', COUNT(*)::VARCHAR
    FROM (
        SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(review_id) > 1
    )

    UNION ALL

    SELECT 'D) orders with > 1 payments', COUNT(*)::VARCHAR
    FROM (
        SELECT order_id FROM order_payments GROUP BY order_id HAVING COUNT(payment_sequential) > 1
    )

    UNION ALL

    -- order status distribution (one row per status)
    SELECT 'E) status: ' || order_status, COUNT(order_id)::VARCHAR
    FROM orders
    GROUP BY order_status

    UNION ALL

    SELECT 'F) delivered orders with NULL delivery date', COUNT(*)::VARCHAR
    FROM orders
    WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL

    UNION ALL

    SELECT 'G) first order date', CAST(MIN(order_purchase_timestamp) AS VARCHAR)
    FROM orders

    UNION ALL

    SELECT 'H) last order date', CAST(MAX(order_purchase_timestamp) AS VARCHAR)
    FROM orders

    UNION ALL

    -- NULL categories are not counted here (COUNT DISTINCT ignores NULL)
    SELECT 'I) categories without translation', COUNT(DISTINCT product_category_name)::VARCHAR
    FROM products
    WHERE NOT EXISTS (SELECT 1 FROM translation WHERE translation.product_category_name = products.product_category_name)

    UNION ALL

    -- justifies the (order, seller) grain of the seller analysis
    SELECT 'K) orders with items from > 1 seller', COUNT(*)::VARCHAR
    FROM (
        SELECT order_id FROM order_items GROUP BY order_id HAVING COUNT(DISTINCT seller_id) > 1
    )

    UNION ALL

    -- justifies the (order, category) grain of the category analysis (NULL category counts as 'unknown')
    SELECT 'L) orders with items from > 1 category', COUNT(*)::VARCHAR
    FROM (
        SELECT i.order_id
        FROM order_items i
        LEFT JOIN products p USING (product_id)
        GROUP BY i.order_id
        HAVING COUNT(DISTINCT COALESCE(p.product_category_name, 'unknown')) > 1
    )

    UNION ALL

    SELECT 'J) orders per month: ' || strftime(order_purchase_timestamp, '%Y-%m'), COUNT(*)::VARCHAR
    FROM orders
    GROUP BY 1
)
SELECT * FROM checks ORDER BY check_name;
