SELECT
	OBJECT_SCHEMA_NAME(i.object_id)		AS SchemaName,
	OBJECT_NAME(i.object_id)			AS TableName,
	i.name								AS IndexName,
	ips.index_type_desc					AS IndexType,
	ips.avg_fragmentation_in_percent	AS FragmentationPercent,
	au.total_pages * 8					AS AllocatedKB
	--'ALTER INDEX ' + i.name + ' ON ' + OBJECT_NAME(i.OBJECT_ID) + ' REBUILD WITH (ONLINE = ON)'
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ips
	INNER JOIN sys.indexes i ON i.object_id = ips.object_id AND ips.index_id = i.index_id
	INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units au ON au.container_id =
		CASE
			WHEN au.[type] IN (1,3) THEN p.hobt_id
			WHEN au.type = 2 THEN p.partition_id
		END
WHERE
	--ips.avg_fragmentation_in_percent > 30 AND
	au.type_desc				= 'IN_ROW_DATA' AND
	ips.alloc_unit_type_desc	= 'IN_ROW_DATA' AND
	ips.database_id				= DB_ID() AND
	i.name						IS NOT NULL
ORDER BY
	OBJECT_SCHEMA_NAME(i.object_id),
	OBJECT_NAME(i.object_id),
	i.name;