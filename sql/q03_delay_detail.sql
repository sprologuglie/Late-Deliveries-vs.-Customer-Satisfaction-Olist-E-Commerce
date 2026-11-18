-- Score distribution inside each delay bucket (% of reviews per score)
WITH base_data AS (
    SELECT
        d.delay_bucket AS bucket,
        r.review_score AS score,
        COUNT(*) AS cnt
    FROM v_delivery d
    JOIN v_orders_scope s USING (order_id)
    JOIN v_reviews r USING (order_id)
    WHERE r.review_score IS NOT NULL
    GROUP BY 1, 2
)
SELECT
    bucket,
    score,
    cnt,
    ROUND(cnt * 100.0 / SUM(cnt) OVER (PARTITION BY bucket), 2) AS pct
FROM base_data
ORDER BY bucket, score;
