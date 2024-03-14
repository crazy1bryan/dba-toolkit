SELECT
	o.name	AS TableName,
	i.name	AS IndexName,
	STATS_DATE(i.object_id, i.index_id) AS StatsDate
FROM sys.objects o
JOIN sys.indexes i ON o.object_id = i.object_id
ORDER BY STATS_DATE(i.object_id, i.index_id) desc;