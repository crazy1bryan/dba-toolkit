DECLARE
	@starttime AS DATETIME = '11/09/2017 18:00',
	@endtime AS DATETIME = '11/09/2017 20:00';

SELECT *
FROM sys.query_store_runtime_stats
WHERE last_execution_time between @starttime and @endtime and plan_id = 10928896
ORDER BY avg_duration DESC;