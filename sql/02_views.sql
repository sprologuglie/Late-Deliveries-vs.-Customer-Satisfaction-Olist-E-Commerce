-- Analysis scope: purchase window and valid statuses.
-- The window keeps the months with meaningful volume (check J in 03_quality_checks.sql);
-- canceled and unavailable orders are excluded.
CREATE OR REPLACE VIEW v_orders_scope AS
  SELECT order_id, order_purchase_timestamp, order_status
  FROM orders
  WHERE order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp <  '2018-09-01'
    AND order_status NOT IN ('canceled', 'unavailable');


-- Revenue components per order (revenue = SUM(price), freight excluded)
CREATE OR REPLACE VIEW v_order_revenues AS
  WITH items AS (
    SELECT order_id,
          SUM(price) AS items_value,
          SUM(freight_value) AS freight,
          COUNT(*) AS n_items
    FROM order_items
    GROUP BY order_id
  ),
  pay AS (
    SELECT order_id, SUM(payment_value) AS paid
    FROM order_payments
    GROUP BY order_id
  )
  SELECT o.order_id, i.n_items, i.items_value, i.freight, p.paid
  FROM orders o
  LEFT JOIN items i USING (order_id)
  LEFT JOIN pay p USING (order_id);


-- Delivery times. Grain: order. Only delivered orders with a delivery date.
-- date_diff('day', ...) counts calendar-day boundaries, so is_late means
-- "delivered on a later calendar day than the estimated delivery date"
-- (a delivery during the estimated day is on time).
-- delay_bucket is the single definition of the delay buckets used by the queries
-- (the numeric prefix keeps them sorted).
CREATE OR REPLACE VIEW v_delivery AS
  WITH d AS (
    SELECT
      o.order_id,
      c.customer_state,
      date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS days_actual,
      date_diff('day', o.order_purchase_timestamp, o.order_estimated_delivery_date) AS days_estimated,
      date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) AS days_late
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
  )
  SELECT
    *,
    days_late > 0 AS is_late,
    CASE WHEN days_late IS NULL THEN NULL
         WHEN days_late <= 0 THEN '0 - On time'
         WHEN days_late <= 3 THEN '1 - 1-3 days late'
         WHEN days_late <= 7 THEN '2 - 4-7 days late'
         ELSE '3 - 8+ days late' END AS delay_bucket
  FROM d;


-- Latest review per order (by answer timestamp; review_id only breaks ties)
CREATE OR REPLACE VIEW v_reviews AS
  SELECT * EXCLUDE (rn) FROM (
    SELECT *,
          ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_answer_timestamp DESC NULLS LAST, review_id
          ) AS rn
    FROM order_reviews
  )
  WHERE rn = 1;


-- (order, seller) pairs. An order with items from several sellers appears once per seller,
-- so seller metrics are at order grain (not item grain).
CREATE OR REPLACE VIEW v_order_sellers AS
  SELECT DISTINCT order_id, seller_id
  FROM order_items;
