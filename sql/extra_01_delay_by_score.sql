-- Delay profile of the orders that received each review score
SELECT
    r.review_score,
    COUNT(*) AS n,
    (1 - AVG(d.is_late::INT)) * 100 AS perc_on_time,
    AVG(CASE WHEN d.is_late AND d.days_late <= 3 THEN 1 ELSE 0 END) * 100 AS perc_1_3_late,
    AVG(CASE WHEN d.days_late > 3 AND d.days_late <= 7 THEN 1 ELSE 0 END) * 100 AS perc_4_7_late,
    AVG(CASE WHEN d.days_late > 7 THEN 1 ELSE 0 END) * 100 AS perc_8_more_late,
    ROUND(AVG(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END), 2) AS avg_delay,
    MEDIAN(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END) AS median_delay,
    QUANTILE_CONT(CASE WHEN d.days_late <= 0 THEN NULL
                    ELSE d.days_late END, 0.9) AS p90_days_late
FROM v_delivery d
JOIN v_orders_scope s USING (order_id)
JOIN v_reviews r USING (order_id)
WHERE r.review_score IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;
