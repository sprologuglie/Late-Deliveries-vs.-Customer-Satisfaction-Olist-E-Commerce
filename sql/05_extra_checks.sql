-- Extra checks used to complete data_dictionary.md and data_quality.md.
-- One row per check, value as text. Run after building the database (build_db.py).
WITH checks AS (
    -- Keys: rows / distinct key values
    SELECT 'K01) orders: rows / distinct order_id' AS check_name,
           COUNT(*) || ' / ' || COUNT(DISTINCT order_id) AS metric_value
    FROM orders
    UNION ALL
    SELECT 'K02) order_items: rows / distinct (order_id, order_item_id)',
           COUNT(*) || ' / ' || COUNT(DISTINCT (order_id, order_item_id))
    FROM order_items
    UNION ALL
    SELECT 'K03) customers: rows / distinct customer_id / distinct customer_unique_id',
           COUNT(*) || ' / ' || COUNT(DISTINCT customer_id) || ' / ' || COUNT(DISTINCT customer_unique_id)
    FROM customers
    UNION ALL
    SELECT 'K04) products: rows / distinct product_id',
           COUNT(*) || ' / ' || COUNT(DISTINCT product_id)
    FROM products
    UNION ALL
    SELECT 'K05) sellers: rows / distinct seller_id',
           COUNT(*) || ' / ' || COUNT(DISTINCT seller_id)
    FROM sellers
    UNION ALL
    SELECT 'K06) order_payments: rows / distinct (order_id, payment_sequential)',
           COUNT(*) || ' / ' || COUNT(DISTINCT (order_id, payment_sequential))
    FROM order_payments
    UNION ALL
    SELECT 'K07) order_reviews: rows / distinct review_id / distinct order_id',
           COUNT(*) || ' / ' || COUNT(DISTINCT review_id) || ' / ' || COUNT(DISTINCT order_id)
    FROM order_reviews
    UNION ALL
    SELECT 'K08) translation: rows / distinct product_category_name',
           COUNT(*) || ' / ' || COUNT(DISTINCT product_category_name)
    FROM translation

    UNION ALL

    -- Column types as inferred by read_csv_auto
    SELECT 'T) column types: ' || table_name,
           string_agg(column_name || ' ' || data_type, ', ' ORDER BY ordinal_position)
    FROM information_schema.columns
    WHERE table_schema = 'main'
      AND table_name IN ('orders', 'order_items', 'customers', 'products', 'sellers',
                         'order_payments', 'order_reviews', 'translation')
    GROUP BY table_name

    UNION ALL

    SELECT 'P) payment_type values', string_agg(DISTINCT payment_type, ', ')
    FROM order_payments

    UNION ALL

    -- Orders without items, by status
    SELECT 'A) orders without items, status: ' || order_status, COUNT(*)::VARCHAR
    FROM orders o
    WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)
    GROUP BY order_status

    UNION ALL

    -- Scope sizes and orders without items inside the delivery scope (decision 4)
    SELECT 'Z1) orders in v_orders_scope', COUNT(*)::VARCHAR
    FROM v_orders_scope
    UNION ALL
    SELECT 'Z2) delivered orders in scope (v_delivery)', COUNT(*)::VARCHAR
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    UNION ALL
    SELECT 'M) delivered orders in scope without items', COUNT(*)::VARCHAR
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = d.order_id)

    UNION ALL

    -- Payments vs items + freight (decision 5): mismatched / compared orders
    SELECT 'R) orders where paid <> items + freight (> 0.01): mismatched / compared',
           COUNT(*) FILTER (WHERE abs(paid - (items_value + freight)) > 0.01) || ' / ' || COUNT(*)
    FROM v_order_revenues
    WHERE items_value IS NOT NULL AND paid IS NOT NULL

    UNION ALL

    -- Reviews answered before the delivery date (delivered orders in scope): before / total
    SELECT 'S) reviews answered before the delivery date: before / total',
           COUNT(*) FILTER (WHERE r.review_answer_timestamp < o.order_delivered_customer_date) || ' / ' || COUNT(*)
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    JOIN v_reviews r USING (order_id)
    JOIN orders o USING (order_id)

    UNION ALL

    -- Categories
    SELECT 'C1) products with NULL category', COUNT(*)::VARCHAR
    FROM products
    WHERE product_category_name IS NULL
    UNION ALL
    SELECT 'C2) products with untranslated category (not NULL)', COUNT(*)::VARCHAR
    FROM products p
    WHERE p.product_category_name IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM translation t WHERE t.product_category_name = p.product_category_name)
    UNION ALL
    SELECT 'C3) untranslated category names', string_agg(DISTINCT p.product_category_name, ', ')
    FROM products p
    WHERE p.product_category_name IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM translation t WHERE t.product_category_name = p.product_category_name)

    UNION ALL

    -- Timestamp order (impossible sequences)
    SELECT 'D1) orders approved before purchase', COUNT(*)::VARCHAR
    FROM orders WHERE order_approved_at < order_purchase_timestamp
    UNION ALL
    SELECT 'D2) orders handed to carrier before approval', COUNT(*)::VARCHAR
    FROM orders WHERE order_delivered_carrier_date < order_approved_at
    UNION ALL
    SELECT 'D3) orders delivered before the carrier date', COUNT(*)::VARCHAR
    FROM orders WHERE order_delivered_customer_date < order_delivered_carrier_date
    UNION ALL
    SELECT 'D4) orders delivered before purchase', COUNT(*)::VARCHAR
    FROM orders WHERE order_delivered_customer_date < order_purchase_timestamp

    UNION ALL

    -- Ranges
    SELECT 'V1) items with price <= 0', COUNT(*)::VARCHAR FROM order_items WHERE price <= 0
    UNION ALL
    SELECT 'V2) items with freight_value < 0', COUNT(*)::VARCHAR FROM order_items WHERE freight_value < 0
    UNION ALL
    SELECT 'V3) reviews with score outside 1-5 or NULL', COUNT(*)::VARCHAR
    FROM order_reviews WHERE review_score IS NULL OR review_score NOT BETWEEN 1 AND 5

    UNION ALL

    -- Referential integrity
    SELECT 'O1) items without product', COUNT(*)::VARCHAR
    FROM order_items i WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.product_id = i.product_id)
    UNION ALL
    SELECT 'O2) items without seller', COUNT(*)::VARCHAR
    FROM order_items i WHERE NOT EXISTS (SELECT 1 FROM sellers s WHERE s.seller_id = i.seller_id)
    UNION ALL
    SELECT 'O3) orders without payments', COUNT(*)::VARCHAR
    FROM orders o WHERE NOT EXISTS (SELECT 1 FROM order_payments p WHERE p.order_id = o.order_id)
    UNION ALL
    SELECT 'O4) orders without customer', COUNT(*)::VARCHAR
    FROM orders o WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id)

    UNION ALL

    -- Time part of the estimated delivery date (affects days_late)
    SELECT 'E1) estimated delivery dates with a non-midnight time', COUNT(*)::VARCHAR
    FROM orders WHERE order_estimated_delivery_date <> date_trunc('day', order_estimated_delivery_date)

    UNION ALL

    -- Null percentages
    SELECT 'N1) % of orders with NULL delivery date (all statuses)',
           ROUND(100.0 * COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) / COUNT(*), 1)::VARCHAR
    FROM orders
    UNION ALL
    SELECT 'N2) % of products with NULL category',
           ROUND(100.0 * COUNT(*) FILTER (WHERE product_category_name IS NULL) / COUNT(*), 1)::VARCHAR
    FROM products
    UNION ALL
    SELECT 'N3) % of reviews with NULL comment title',
           ROUND(100.0 * COUNT(*) FILTER (WHERE review_comment_title IS NULL) / COUNT(*), 1)::VARCHAR
    FROM order_reviews
    UNION ALL
    SELECT 'N4) % of reviews with NULL comment message',
           ROUND(100.0 * COUNT(*) FILTER (WHERE review_comment_message IS NULL) / COUNT(*), 1)::VARCHAR
    FROM order_reviews
)
SELECT * FROM checks ORDER BY check_name;
