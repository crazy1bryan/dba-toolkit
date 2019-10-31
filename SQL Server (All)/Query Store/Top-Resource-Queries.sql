-- Get total resources consumed
DECLARE @TotalCPUMilliseconds	BIGINT;
DECLARE @TotalLogicalWrites		BIGINT;
DECLARE @TotalLogicalReads		BIGINT;

SELECT
	@TotalCPUMilliseconds = SUM(CAST(count_executions AS FLOAT(53)) * CAST(avg_cpu_time AS FLOAT(53))),
	@TotalLogicalWrites = SUM(CAST(count_executions AS FLOAT(53)) * CAST(avg_logical_io_writes AS FLOAT(53))),
	@TotalLogicalReads = SUM(CAST(count_executions AS FLOAT(53)) * CAST(avg_logical_io_reads AS FLOAT(53)))
FROM sys.query_store_runtime_stats;

-- CPU
SELECT TOP 5
	qs.query_id,
	t.query_sql_text,
	CPUMilliseconds / @TotalCPUMilliseconds AS CPUPercentOfTotal
FROM
	(SELECT
		q.query_id,
		q.query_text_id,
		SUM(CAST(qsrs.count_executions AS FLOAT(53)) * CAST(qsrs.avg_cpu_time AS FLOAT(53))) AS CPUMilliseconds
	FROM sys.query_store_query AS q
		INNER JOIN sys.query_store_plan AS p on p.query_id = q.query_id
		INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsrs.plan_id = p.plan_id
	GROUP BY
		q.query_id,
		q.query_text_id) AS qs
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = qs.query_text_id
ORDER BY CPUMilliseconds DESC;

-- Logical writes
SELECT TOP 5
	qs.query_id,
	t.query_sql_text,
	LogicalWrites / @TotalLogicalWrites AS LogicalWritesPercentOfTotal
FROM
	(SELECT
		q.query_id,
		q.query_text_id,
		SUM(CAST(qsrs.count_executions AS FLOAT(53)) * CAST(qsrs.avg_logical_io_writes AS FLOAT(53))) AS LogicalWrites
	FROM sys.query_store_query AS q
		INNER JOIN sys.query_store_plan AS p on p.query_id = q.query_id
		INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsrs.plan_id = p.plan_id
	GROUP BY
		q.query_id,
		q.query_text_id) AS qs
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = qs.query_text_id
ORDER BY LogicalWrites DESC;

-- Logical reads
SELECT TOP 5
	qs.query_id,
	t.query_sql_text,
	LogicalReads / @TotalLogicalReads AS LogicalReadsPercentOfTotal
FROM
	(SELECT
		q.query_id,
		q.query_text_id,
		SUM(CAST(qsrs.count_executions AS FLOAT(53)) * CAST(qsrs.avg_logical_io_reads AS FLOAT(53))) AS LogicalReads
	FROM sys.query_store_query AS q
		INNER JOIN sys.query_store_plan AS p on p.query_id = q.query_id
		INNER JOIN sys.query_store_runtime_stats AS qsrs ON qsrs.plan_id = p.plan_id
	GROUP BY
		q.query_id,
		q.query_text_id) AS qs
	INNER JOIN sys.query_store_query_text AS t on t.query_text_id = qs.query_text_id
ORDER BY LogicalReads DESC;