-- TODO: grain (ordine, categoria); documenta come tratti gli ordini multi-categoria

SELECT 
    t.product_category_name_english AS category,
    ROUND(AVG(CASE WHEN is_late THEN NULL ELSE r.review_score END), 2) AS avg_score_on_time,
    ROUND(AVG(CASE WHEN days_late <= 7 THEN NULL ELSE r.review_score END), 2) AS avg_score_8_plus_days_late
FROM v_delivery
LEFT JOIN v_reviews r USING(order_id)
LEFT JOIN order_items i USING(order_id)
LEFT JOIN products p USING(product_id)
LEFT JOIN translation t USING(product_category_name)
WHERE t.product_category_name_english IS NOT NULL
    AND order_id IN (SELECT order_id FROM v_orders_scope)
GROUP BY t.product_category_name_english