SELECT
	wait_category_desc,
	SUM(total_query_wait_time_ms) AS OverallSumWaitTime(ms)]
FROM sys.query_store_wait_stats
WHERE plan_id = 47
GROUP BY wait_category_desc;