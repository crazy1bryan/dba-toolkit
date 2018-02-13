SELECT
	sc.name	AS SchemaName,
	o.name AS ObjectName,
	i.name AS IndexName,
	i.index_id,
	s.user_seeks,
	s.user_scans, 
	s.user_lookups,
	s.user_seeks + s.user_scans + s.user_lookups AS TotalReads,
	s.user_updates
FROM sys.dm_db_index_usage_stats s 
	JOIN sys.indexes i ON i.object_id = s.object_id AND i.index_id = s.index_id
	JOIN sys.objects o ON o.object_id = i.object_id
	JOIN sys.schemas sc ON sc.schema_id = o.schema_id
WHERE
	o.type = 'U'
ORDER BY
	SchemaName,
	ObjectName,
	IndexName;