-- WITH distinct_sellers AS (SELECT COUNT(DISTINCT seller_id) AS n_distinct_sellers FROM order_items GROUP BY order_id)
--SELECT COUNT(*) FROM distinct_sellers WHERE n_distinct_sellers > 1;

WITH seller_stats AS (
    SELECT 
        s.seller_id,
        customer_state,
        AVG(is_late::INT) * 100 AS perc_late_orders,
        SUM(is_late::INT) AS late_orders,
        COUNT(DISTINCT order_id) AS n_orders
    FROM v_delivery
    LEFT JOIN order_items i USING(order_id)
    LEFT JOIN sellers s USING(seller_id)
    WHERE order_id IN (SELECT order_id FROM v_orders_scope)
    GROUP BY customer_state, s.seller_id
    HAVING COUNT(DISTINCT order_id) > 30
)
SELECT *, RANK() OVER (PARTITION BY customer_state ORDER BY perc_late_orders DESC) AS rank_in_state
FROM seller_stats
