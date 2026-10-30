WITH base AS (
  SELECT date_trunc('month', o.order_purchase_timestamp) AS month,
         r.items_value
  FROM orders o
  JOIN v_order_revenues r USING (order_id)
  WHERE o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
    AND o.order_status NOT IN ('canceled', 'unavailable')  -- decisione da documentare
    AND r.items_value IS NOT NULL
),
monthly AS (
  SELECT month,
         COUNT(*)         AS n_orders,
         SUM(items_value) AS revenue
  FROM base
  GROUP BY month
)
SELECT month,
       n_orders,
       revenue,
       revenue / n_orders                                  AS aov,
       AVG(n_orders) OVER w                                AS n_orders_ma3,       
       SUM(revenue) OVER w                                 AS revenure_ma3
       SUM(revenue) OVER w / SUM(n_orders) OVER w          AS aov_ma3,  -- media pesata
       n_orders - LAG(n_orders) OVER (ORDER BY month)      AS n_orders_delta,
       revenue  - LAG(revenue)  OVER (ORDER BY month)      AS revenue_delta,
       n_orders - LAG(n_orders) OVER (ORDER BY month)      as aov_delta
FROM monthly
WINDOW w AS (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY month;