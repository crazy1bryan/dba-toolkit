;WITH CPUUsage (query_text_id, sum_executions, sum_cpu_time_seconds) AS
(
    SELECT
        q.query_text_id,
        SUM(rs.count_executions),
        SUM(CONVERT(NUMERIC(10, 0), (rs.avg_cpu_time * rs.count_executions / 1000)))
    FROM sys.query_store_query q
        INNER JOIN sys.query_store_plan p ON q.query_id = p.query_id
        INNER JOIN sys.query_store_runtime_stats rs ON p.plan_id = rs.plan_id
    WHERE
        rs.first_execution_time >= '2017-05-16'
    GROUP BY
        q.query_text_id
)
SELECT
    c.sum_executions,
    c.sum_cpu_time_seconds,
    qt.query_sql_text
FROM CPUUsage c
    INNER JOIN sys.query_store_query_text qt ON qt.query_text_id = c.query_text_id
ORDER BY c.sum_cpu_time_seconds DESC;