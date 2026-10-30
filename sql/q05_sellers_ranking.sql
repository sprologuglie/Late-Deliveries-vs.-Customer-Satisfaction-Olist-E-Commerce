WITH seller_stats AS (
    SELECT 
        s.seller_id,
        s.seller_state,
        AVG(is_late::INT) * 100 AS perc_late_orders,
    FROM v_delivery
    LEFT JOIN order_items i USING(order_id)
    LEFT JOIN sellers s USING(seller_id)
    LEFT JOIN orders o USING(order_id)
    WHERE o.order_purchase_timestamp >= '2017-01-01'  -- Stessi filtri di q2
            AND o.order_purchase_timestamp < '2018-09-01'
            AND o.order_status NOT IN ('canceled', 'unavailable')
            AND i.price IS NOT NULL
    GROUP BY s.seller_state, s.seller_id
    HAVING COUNT(i.order_id) > 30
    ORDER BY s.seller_state, perc_late_orders DESC
)
SELECT *, RANK() OVER (PARTITION BY seller_state ORDER BY perc_late_orders DESC) AS rank_in_state
FROM seller_stats
