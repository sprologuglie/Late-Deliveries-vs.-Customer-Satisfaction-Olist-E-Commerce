# Data exploration

## Datasets

| Table          | Descrizione provvisoria italiano | Numero di righe |
| -------------- | -------------------------------- | --------------- |
| orders         | ordini                           | 99441           |
| order_items    | prodotti acquistati negli ordini | 112650          |
| customers      | clienti                          | 99441           |
| products       | prodotti                         | 32951           |
| sellers        | venditori                        | 3095            |
| order_payments | pagamenti                        | 103886          |
| order_reviews  | recensioni                       | 99224           |
| geolocation    | coordinate e città               | 1000163         |
| transation     | traduzione inglese               | 71              |


## TABLES

1. Orders 

KEY: order_id

────────────────────────────────────────────────────────────────────────────
 column_name                   │ column_type │ null │ key  │ default │ extra
───────────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 order_id                      │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 customer_id                   │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 order_status                  │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 order_purchase_timestamp      │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 
 order_approved_at             │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 
 order_delivered_carrier_date  │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 


2. Order items

KEY: order_id, order_item_id

──────────────────────────────────────────────────────────────────
 column_name         │ column_type │ null │ key  │ default │ extra
─────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 order_id            │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 order_item_id       │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_id          │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 seller_id           │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 shipping_limit_date │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 
 price               │ DOUBLE      │ YES  │ NULL │ NULL    │ NULL 

3. Customers

KEY: customer_id

───────────────────────────────────────────────────────────────────────
 column_name              │ column_type │ null │ key  │ default │ extra
──────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 customer_id              │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 customer_unique_id       │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 customer_zip_code_prefix │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 customer_city            │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 customer_state           │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
───────────────────────────────────────────────────────────────────────

4. Products

KEY: product_id

─────────────────────────────────────────────────────────────────────────
 column_name                │ column_type │ null │ key  │ default │ extra
────────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 product_id                 │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 product_category_name      │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 product_name_lenght        │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_description_lenght │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_photos_qty         │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_weight_g           │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_length_cm          │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_height_cm          │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 product_width_cm           │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
─────────────────────────────────────────────────────────────────────────

5. Sellers

KEY: seller_id

─────────────────────────────────────────────────────────────────────
 column_name            │ column_type │ null │ key  │ default │ extra
────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 seller_id              │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 seller_zip_code_prefix │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 seller_city            │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 seller_state           │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
─────────────────────────────────────────────────────────────────────

6. Payments

KEY: order_id, payment_sequential

───────────────────────────────────────────────────────────────────
 column_name          │ column_type │ null │ key  │ default │ extra
──────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 order_id             │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 payment_sequential   │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 payment_type         │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 payment_installments │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 payment_value        │ DOUBLE      │ YES  │ NULL │ NULL    │ NULL 
───────────────────────────────────────────────────────────────────

7. Reviews

KEY: review_id --> CLEANING NEEDED!!

──────────────────────────────────────────────────────────────────────
 column_name             │ column_type │ null │ key  │ default │ extra
─────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 review_id               │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 order_id                │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 review_score            │ BIGINT      │ YES  │ NULL │ NULL    │ NULL 
 review_comment_title    │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 review_comment_message  │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 review_creation_date    │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 
 review_answer_timestamp │ TIMESTAMP   │ YES  │ NULL │ NULL    │ NULL 
──────────────────────────────────────────────────────────────────────

8. Transaltions

KEY: product_category_name 

────────────────────────────────────────────────────────────────────────────
 column_name                   │ column_type │ null │ key  │ default │ extra
───────────────────────────────┼─────────────┼──────┼──────┼─────────┼───────
 product_category_name         │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
 product_category_name_english │ VARCHAR     │ YES  │ NULL │ NULL    │ NULL 
────────────────────────────────────────────────────────────────────────────