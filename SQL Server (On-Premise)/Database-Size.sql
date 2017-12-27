SELECT
	DB_NAME(database_id)                                        AS DatabaseName,
	SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8 / 1024    AS DataSizeMB,
	SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8 / 1024    AS LogSizeMB,
	SUM(size) * 8 / 1024                                        AS TotalSizeMB
FROM sys.master_files
GROUP BY database_id;