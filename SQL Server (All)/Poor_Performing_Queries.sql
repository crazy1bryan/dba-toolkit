SELECT TOP 20
	SUBSTRING(qt.TEXT, (qs.statement_start_offset / 2) + 1,
		((CASE qs.statement_end_offset
		WHEN -1 THEN DATALENGTH(qt.TEXT)
		ELSE qs.statement_end_offset
		END - qs.statement_start_offset) / 2) + 1) AS Query,
	qs.creation_time,
	qs.execution_count,
	qs.total_worker_time,
	qs.total_logical_reads,
	qs.total_logical_writes,
	qs.total_elapsed_time / 1000 total_elapsed_time_MS,
	qs.total_elapsed_time / 1000 / qs.execution_count avg_elapsed_time_MS,
	qp.query_plan
FROM
	sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
-- WHERE last_execution_time >= '2016-01-19 22:00'
 ORDER BY qs.total_worker_time DESC            -- CPU time
-- ORDER BY qs.total_logical_reads DESC        -- logical reads
-- ORDER BY qs.total_logical_writes DESC    -- logical writes
-- ORDER BY avg_elapsed_time_MS DESC        -- Average elapsed time
;