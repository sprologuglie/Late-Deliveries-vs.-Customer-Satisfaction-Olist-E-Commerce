-- Vista order_revenues

CREATE VIEW v_order_revenues AS
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