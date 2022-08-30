SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type LIKE '%RBIO_RG%';

SELECT * FROM sys.dm_db_wait_stats
WHERE wait_type LIKE '%RBIO%';