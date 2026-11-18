-- Monthly orders, revenue (SUM(price)) and AOV, with 3-month moving averages and month-on-month deltas.
-- The moving averages are NULL until a full 3-month window is available.
WITH base AS (
  SELECT date_trunc('month', s.order_purchase_timestamp) AS month,
         r.items_value
  FROM v_orders_scope s
  JOIN v_order_revenues r USING (order_id)
  WHERE r.items_value IS NOT NULL
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
       CASE WHEN COUNT(*) OVER w = 3 THEN AVG(n_orders) OVER w END                       AS n_orders_ma3,
       CASE WHEN COUNT(*) OVER w = 3 THEN AVG(revenue) OVER w END                        AS revenue_ma3,
       CASE WHEN COUNT(*) OVER w = 3 THEN SUM(revenue) OVER w / SUM(n_orders) OVER w END AS aov_ma3,  -- weighted mean
       n_orders - LAG(n_orders) OVER (ORDER BY month)      AS n_orders_delta,
       revenue  - LAG(revenue)  OVER (ORDER BY month)      AS revenue_delta,
       aov - LAG(aov) OVER (ORDER BY month)                AS aov_delta
FROM monthly
WINDOW w AS (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY month;
