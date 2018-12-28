SELECT
	name, last_execution_time
FROM sys.procedures p
	LEFT JOIN sys.dm_exec_procedure_stats ps
		ON p.object_id = ps.object_id