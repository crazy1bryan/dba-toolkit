DECLARE @query_text AS VARCHAR(MAX) = '%Query Substring Here%';

SELECT
	q.query_id,
	t.query_sql_text,
	*
FROM sys.query_store_query AS q
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = q.query_text_id
WHERE
	t.query_sql_text like @query_text
	AND last_execution_time >= '2017-11-28';