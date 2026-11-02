-- Vista con filtri di validità per mesi incompleti e ordini cancellati
CREATE OR REPLACE VIEW v_orders_scope AS
  SELECT order_id, order_purchase_timestamp, order_status
  FROM orders
  WHERE order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp <  '2018-09-01'
    AND order_status NOT IN ('canceled', 'unavailable');


-- Vista con revenues
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

-- Vista per tempi di consegna
CREATE OR REPLACE VIEW v_delivery AS
  SELECT
    o.order_id,
    c.customer_state,
    date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS days_actual,
    date_diff('day', o.order_purchase_timestamp, o.order_estimated_delivery_date) AS days_estimated,
    date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) AS days_late,
    (o.order_delivered_customer_date > o.order_estimated_delivery_date AND days_late > 0) AS is_late
  FROM orders o
  JOIN customers c USING (customer_id)
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL;

  -- Vista per deduplica reviews
CREATE OR REPLACE VIEW v_reviews AS
  SELECT * EXCLUDE (rn) FROM (
    SELECT *,
          ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_id, review_answer_timestamp DESC) AS rn
    FROM order_reviews
  )
  WHERE rn = 1;