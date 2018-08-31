SELECT TOP 20
	p.query_id,
	ISNULL(OBJECT_NAME(q.object_id), '')												AS object_name,
	qt.query_sql_text,
	ROUND(CONVERT(FLOAT, SUM(rs.avg_logical_io_reads * rs.count_executions)) * 8, 2)	AS total_logical_io_reads,
	SUM(rs.count_executions)															AS execution_count
FROM sys.query_store_runtime_stats rs
	INNER JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
	INNER JOIN sys.query_store_query q ON q.query_id = p.query_id
	INNER JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
WHERE NOT (rs.first_execution_time < '2018-08-24' OR rs.last_execution_time > '2018-09-01')
GROUP BY
	p.query_id,
	qt.query_sql_text,
	q.object_id
HAVING COUNT(DISTINCT p.plan_id) >= 1
ORDER BY total_logical_io_reads DESC