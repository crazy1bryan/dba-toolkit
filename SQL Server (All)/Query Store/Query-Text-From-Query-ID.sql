SELECT
	t.query_sql_text
FROM sys.query_store_query AS q
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = q.query_text_id
WHERE
	q.query_id = [YouQueryIDHere];