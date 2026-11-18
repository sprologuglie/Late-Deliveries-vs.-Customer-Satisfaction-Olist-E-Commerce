-- Seller ranking by late orders.
-- Grain: (order, seller) via v_order_sellers. An order with items from several sellers
-- counts once for each seller (see check K in 03_quality_checks.sql).
-- All sellers are returned: concentration (Pareto) is computed on all late orders,
-- not on a subset. Late RATES are only meaningful with enough orders, so
-- meets_min_sample flags sellers with at least 30 orders and rank_late_rate
-- ranks only those.
WITH seller_stats AS (
    SELECT
        os.seller_id,
        COUNT(*) AS n_orders,
        SUM(d.is_late::INT) AS late_orders,
        AVG(d.is_late::INT) * 100 AS perc_late_orders,
        COUNT(*) >= 30 AS meets_min_sample
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    JOIN v_order_sellers os USING (order_id)
    GROUP BY os.seller_id
)
SELECT
    *,
    CASE WHEN meets_min_sample
         THEN RANK() OVER (PARTITION BY meets_min_sample ORDER BY perc_late_orders DESC)
    END AS rank_late_rate
FROM seller_stats
ORDER BY late_orders DESC, seller_id;
