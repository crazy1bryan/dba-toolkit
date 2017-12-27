SELECT
    CONVERT(XML, det.query_plan)    AS ExecutionPlan,
    dest.text                        AS SQLText,
    des.session_id,
    des.login_name,
    des.host_name,
    des.program_name,
    des.cpu_time,
    des.memory_usage,
    des.total_elapsed_time,
    des.reads,
    des.writes,
    des.logical_reads,
    der.command,
    der.last_wait_type,
    der.percent_complete
FROM sys.dm_exec_requests der
    INNER JOIN sys.dm_exec_sessions des ON des.session_id = der.session_id
    OUTER APPLY sys.dm_exec_text_query_plan (der.plan_handle, der.statement_start_offset, der.statement_end_offset) det
    CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS dest;