-- CREAZIONE TABELLE DA CSV

-- 1. Tabella Clienti
CREATE OR REPLACE TABLE customers AS 
SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');

-- 2. Tabelle Ordini
CREATE OR REPLACE TABLE orders AS 
SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');

CREATE OR REPLACE TABLE order_items AS 
SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');

CREATE OR REPLACE TABLE order_payments AS 
SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');

CREATE OR REPLACE TABLE order_reviews AS 
SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');

-- 3. Tabella Prodotti
CREATE OR REPLACE TABLE products AS 
SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

-- 4. Tabella Venditori
CREATE OR REPLACE TABLE sellers AS 
SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');


-- 5. Tabella traduzioni categorie
CREATE OR REPLACE TABLE translation AS 
SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');