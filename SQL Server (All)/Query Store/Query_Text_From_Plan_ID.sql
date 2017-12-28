DECLARE @plan_id AS BIGINT = planId_goes_here;

SELECT
	t.query_sql_text
FROM sys.query_store_plan AS p
	INNER JOIN sys.query_store_query AS q on q.query_id = p.query_id
	INNER JOIN  sys.query_store_query_text AS t on t.query_text_id = q.query_text_id
WHERE p.plan_id = @plan_id;