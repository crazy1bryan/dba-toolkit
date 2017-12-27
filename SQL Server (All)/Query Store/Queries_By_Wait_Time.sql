SELECT
	qt.query_text_id,
	q.query_id,
	p.plan_id,
	SUM(total_query_wait_time_ms) as sum_total_wait_ms
FROM sys.query_store_wait_stats AS ws
    INNER JOIN sys.query_store_plan AS p on ws.plan_id = p.plan_id
    INNER JOIN sys.query_store_query AS q on p.query_id = q.query_id
    INNER JOIN sys.query_store_query_text AS qt on q.query_text_id = qt.query_text_id
GROUP BY qt.query_text_id, q.query_id, p.plan_id
ORDER BY sum_total_wait_ms DESC;