-- CREATE TABLES FROM CSV (paths are relative to the repo root)

-- 1. Customers
CREATE OR REPLACE TABLE customers AS 
SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');

-- 2. Orders, items, payments, reviews
CREATE OR REPLACE TABLE orders AS 
SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');

CREATE OR REPLACE TABLE order_items AS 
SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');

CREATE OR REPLACE TABLE order_payments AS 
SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');

CREATE OR REPLACE TABLE order_reviews AS 
SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');

-- 3. Products
CREATE OR REPLACE TABLE products AS 
SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

-- 4. Sellers
CREATE OR REPLACE TABLE sellers AS 
SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');


-- 5. Category name translation
CREATE OR REPLACE TABLE translation AS 
SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');