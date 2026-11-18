-- EXPLORATORY: table schemas and key checks (not needed to reproduce the results)

-- TABLE SCHEMAS

DESCRIBE SELECT *
FROM orders;
DESCRIBE SELECT *
FROM order_items;
DESCRIBE SELECT *
FROM customers;
DESCRIBE SELECT *
FROM products;
DESCRIBE SELECT *
FROM sellers;
DESCRIBE SELECT *
FROM order_payments;
DESCRIBE SELECT *
FROM order_reviews;
DESCRIBE SELECT *
FROM translation;

-- IDENTIFY KEYS

-- 1. ORDERS
-- order_id is the primary key

SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT order_id) AS n_order_ids
FROM orders;

SELECT 
    COUNT(*) AS n_null_order_id
FROM orders
WHERE order_id IS NULL;

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. ORDER ITEMS
-- composite key: order_id + order_item_id
SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT order_id) AS n_order_ids,
    COUNT(DISTINCT order_item_id) AS n_order_item_ids
FROM order_items;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (order_id, order_item_id)) AS distinct_combinations
FROM order_items;

SELECT 
    COUNT(*) AS n_null_combinations
FROM order_items
WHERE order_id IS NULL OR order_item_id IS NULL;

-- 3. CUSTOMERS
-- customer_id (not customer_unique_id) is the primary key

SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT customer_id) AS n_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS n_customer_unique_ids
FROM customers;

SELECT 
    COUNT(*) AS n_null_customer_id
FROM customers
WHERE customer_id IS NULL;


-- 4. PRODUCTS

SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT product_id) AS n_product_ids
FROM products;

SELECT 
    COUNT(*) AS n_null_product_id
FROM products
WHERE product_id IS NULL;

-- 5. SELLERS

SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT seller_id) AS n_seller_ids
FROM sellers;

SELECT 
    COUNT(*) AS n_null_seller_id
FROM sellers
WHERE seller_id IS NULL;

-- 6. PAYMENTS
-- composite key again: order_id + payment_sequential
SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT order_id) AS n_order_ids,
    COUNT(DISTINCT payment_sequential) AS n_payment_sequential 
FROM order_payments;

SELECT 
    COUNT(*) AS n_rows,
    COUNT(DISTINCT (order_id, payment_sequential)) AS distinct_combinations
FROM order_payments;

SELECT 
    COUNT(*) AS n_null_order_id
FROM order_payments
WHERE order_id IS NULL;

-- 7. REVIEWS
-- review_id looks like a key but is not unique, and order_id repeats too: no usable key (see data_quality.md)
SELECT 
    COUNT(*) AS n_rows, 
    COUNT(DISTINCT review_id) AS n_review_ids
FROM order_reviews;

SELECT COUNT(*) AS null_review_id
FROM order_reviews
WHERE review_id IS NULL;

-- 8. TRANSLATION

SELECT 
    COUNT(*) AS n_rows, 
    COUNT(DISTINCT product_category_name) AS n_category_names
FROM translation;

SELECT COUNT(*) AS null_names
FROM translation
WHERE product_category_name IS NULL;