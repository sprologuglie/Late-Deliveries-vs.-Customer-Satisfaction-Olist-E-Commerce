SELECT 
    r.review_score,
    COUNT(*) AS n,
    (1 - AVG(is_late::INT)) * 100 AS perc_on_time,
    AVG(CASE WHEN is_late AND days_late <= 3 THEN 1 ELSE 0 END) * 100 AS perc_1_3_late,
    AVG(CASE WHEN days_late > 3 AND days_late <= 7 THEN 1 ELSE 0 END) * 100 AS perc_3_7_late,
    AVG(CASE WHEN days_late > 7 THEN 1 ELSE 0 END) * 100 AS perc_8_more_late,
    ROUND(AVG(CASE WHEN days_late <= 0 THEN NULL 
                    ELSE days_late END), 2) AS avg_delay,
    MEDIAN(CASE WHEN days_late <= 0 THEN NULL 
                    ELSE days_late END) AS median_delay,  
    QUANTILE_CONT(CASE WHEN days_late <= 0 THEN NULL 
                    ELSE days_late END, 0.9) AS p90_days_late,                  
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
WHERE r.review_score IS NOT NULL
    AND order_id IN (SELECT order_id FROM v_orders_scope)
GROUP BY r.review_score
ORDER BY r.review_score;