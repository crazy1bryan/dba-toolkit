DECLARE @query_text AS VARCHAR(MAX) = '%License%';

SELECT
	t.query_sql_text,
	q.query_id,
	p.plan_id,
	qsrs.*
FROM sys.query_store_query AS q
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = q.query_text_id
	INNER JOIN sys.query_store_plan AS p on p.query_id = q.query_id
	INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsrs.plan_id = p.plan_id
WHERE
	t.query_sql_text like @query_text
	AND p.last_execution_time >= '2018-08-28'
ORDER BY
	q.query_id,
	p.plan_id;