SELECT 'ordini senza items' AS check_name, COUNT(*) AS metric_value
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)

UNION ALL

SELECT 'items senza order', COUNT(*)
FROM order_items
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.order_id = order_items.order_id)

UNION ALL

SELECT 'ordini con > 1 recensioni', COUNT(*)
FROM (
    SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(review_id) > 1
)

UNION ALL

SELECT 'ordini con > 1 pagamenti', COUNT(*)
FROM (
    SELECT order_id FROM order_payments GROUP BY order_id HAVING COUNT(payment_sequential) > 1
)

UNION ALL

-- Qui uniamo anche il dettaglio degli stati ordine (restituirà una riga per ogni stato)
SELECT 'stato: ' || order_status, COUNT(order_id)
FROM orders
GROUP BY order_status

UNION ALL

SELECT 'delivered order with NULL delivery date', COUNT(*)
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL

UNION ALL

-- Per data primo ordine (convertiamo la data in stringa per compatibilità)
SELECT 'first order date', CAST(MIN(order_approved_at) AS VARCHAR)
FROM orders

UNION ALL

-- Per data ultimo ordine
SELECT 'last order date', CAST(MAX(order_approved_at) AS VARCHAR)
FROM orders

UNION ALL

SELECT 'categorie senza traduzione', COUNT(DISTINCT product_category_name)
FROM products
WHERE NOT EXISTS (SELECT 1 FROM translation WHERE translation.product_category_name = products.product_category_name);