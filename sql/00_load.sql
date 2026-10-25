-- CREAZIONE TABELLE DA CSV

-- 1. Tabella Clienti
CREATE TABLE IF NOT EXISTS customers AS 
SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');

-- 2. Tabelle Ordini
CREATE TABLE IF NOT EXISTS orders AS 
SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');

CREATE TABLE IF NOT EXISTS order_items AS 
SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');

CREATE TABLE IF NOT EXISTS order_payments AS 
SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');

CREATE TABLE IF NOT EXISTS order_reviews AS 
SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');

-- 3. Tabella Prodotti
CREATE TABLE IF NOT EXISTS products AS 
SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

-- 4. Tabella Venditori
CREATE TABLE IF NOT EXISTS sellers AS 
SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');

-- 5. Tabella Geolocation
CREATE TABLE IF NOT EXISTS geolocation AS 
SELECT * FROM read_csv_auto('data/olist_geolocation_dataset.csv');

-- 6. Tabella traduzioni categorie
CREATE TABLE IF NOT EXISTS translation AS 
SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');