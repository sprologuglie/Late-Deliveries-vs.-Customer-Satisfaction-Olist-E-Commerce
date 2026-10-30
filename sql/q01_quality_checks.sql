SELECT 'A) ordini senza items' AS check_name, COUNT(*) AS metric_value
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)

UNION ALL

SELECT 'B) items senza order', COUNT(*)
FROM order_items
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE orders.order_id = order_items.order_id)

UNION ALL

SELECT 'C) ordini con > 1 recensioni', COUNT(*)
FROM (
    SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(review_id) > 1
)

UNION ALL

SELECT 'D) ordini con > 1 pagamenti', COUNT(*)
FROM (
    SELECT order_id FROM order_payments GROUP BY order_id HAVING COUNT(payment_sequential) > 1
)

UNION ALL

-- Qui uniamo anche il dettaglio degli stati ordine (restituirà una riga per ogni stato)
SELECT 'E) stato: ' || order_status, COUNT(order_id)
FROM orders
GROUP BY order_status

UNION ALL

SELECT 'F) delivered order with NULL delivery date', COUNT(*)
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL

UNION ALL

-- Per data primo ordine (convertiamo la data in stringa per compatibilità)
SELECT 'G) first order date', CAST(MIN(order_purchase_timestamp) AS VARCHAR)
FROM orders

UNION ALL

-- Per data ultimo ordine
SELECT 'H) last order date', CAST(MAX(order_purchase_timestamp) AS VARCHAR)
FROM orders

UNION ALL

SELECT 'I) categorie senza traduzione', COUNT(DISTINCT product_category_name)
FROM products
WHERE NOT EXISTS (SELECT 1 FROM translation WHERE translation.product_category_name = products.product_category_name)

UNION ALL

SELECT 'J) ordini per mese: ' || date_trunc('month', order_purchase_timestamp) AS month, COUNT(*) AS n_orders
FROM orders
GROUP BY 1
ORDER BY check_name;