-- TREND MENSILI + MEDIA MOBILE
-- Numero di ordini
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS month,
        COUNT(*) AS n_orders
    FROM orders
    GROUP BY month
),
numbered_monthly AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY month) AS n_row,
        COUNT(*) OVER () AS total_rows
    FROM monthly
),
filtered_monthly AS (
    SELECT month, n_orders
    FROM numbered_monthly
    WHERE n_row > 1 AND n_row < total_rows
)
SELECT month, n_orders,
       AVG(n_orders) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma3,
       n_orders - LAG(n_orders) OVER (ORDER BY month) AS delta
FROM filtered_monthly
ORDER BY month;

-- Incasso
WITH orders_revenue AS (
    SELECT o.order_id, o.order_purchase_timestamp, r.items_value AS revenue -- REVENUE DEFINED AS SUM(price)
    FROM v_order_revenues r
    LEFT JOIN orders o USING(order_id)
),
monthly AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS month,
        SUM(revenue) AS monthly_revenue
    FROM orders_revenue
    GROUP BY month
),
numbered_monthly AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY month) AS n_row,
        COUNT(*) OVER () AS total_rows
    FROM monthly
),
filtered_monthly AS (
    SELECT month, monthly_revenue
    FROM numbered_monthly
    WHERE n_row > 1 AND n_row < total_rows
)
SELECT month, monthly_revenue,
       AVG(monthly_revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma3,
       monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month) AS delta
FROM filtered_monthly
ORDER BY month;

-- Ticket
WITH orders_revenue AS (
    SELECT o.order_id, o.order_purchase_timestamp, r.items_value AS revenue
    FROM v_order_revenues r
    LEFT JOIN orders o USING(order_id)
),
monthly AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS month,
        SUM(revenue) AS monthly_revenue,
        COUNT(*) AS n_orders
    FROM orders_revenue
    GROUP BY month
),
numbered_monthly AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY month) AS n_row,
        COUNT(*) OVER () AS total_rows
    FROM monthly
),
filtered_monthly AS (
    SELECT month, monthly_revenue, n_orders
    FROM numbered_monthly
    WHERE n_row > 1 AND n_row < total_rows
)
SELECT month, monthly_revenue / n_orders AS monthly_ticket,
       AVG(monthly_ticket) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma3,
       monthly_ticket - LAG(monthly_ticket) OVER (ORDER BY month) AS delta
FROM filtered_monthly
ORDER BY month;
