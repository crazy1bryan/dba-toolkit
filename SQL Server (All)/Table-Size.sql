SELECT
	OBJECT_NAME(i.object_id) AS TableName,
	MAX(p.[rows]) AS NumRows,
	SUM(au.total_pages) AS NumPages,
	SUM(au.total_pages * 8) / 1024 AS TotalMB,
	SUM(au.used_pages * 8) / 1024 AS UsedMB,
	SUM(au.data_pages * 8) / 1024 AS DataMB
FROM sys.indexes i
	INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units au ON
		CASE
		WHEN au.[type] IN (1, 3) THEN p.hobt_id
		WHEN au.type = 2 THEN p.partition_id
		END = au.container_id
	INNER JOIN sys.objects o ON i.object_id = o.object_id
WHERE o.is_ms_shipped <> 1
GROUP BY OBJECT_NAME(i.object_id)
ORDER BY TotalMB DESC;