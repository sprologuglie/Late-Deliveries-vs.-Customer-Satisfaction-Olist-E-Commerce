-- Sellers ranked by late rate within each customer state.
-- Grain: (order, seller) via v_order_sellers; minimum 30 orders per (seller, state) pair.
-- A seller can appear in several states: rows are seller-state pairs, not sellers.
WITH seller_state_stats AS (
    SELECT
        os.seller_id,
        d.customer_state,
        COUNT(*) AS n_orders,
        SUM(d.is_late::INT) AS late_orders,
        AVG(d.is_late::INT) * 100 AS perc_late_orders
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    JOIN v_order_sellers os USING (order_id)
    GROUP BY os.seller_id, d.customer_state
    HAVING COUNT(*) >= 30
)
SELECT
    *,
    RANK() OVER (PARTITION BY customer_state ORDER BY perc_late_orders DESC) AS rank_in_state
FROM seller_state_stats
ORDER BY customer_state, rank_in_state;
