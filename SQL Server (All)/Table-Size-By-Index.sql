SELECT
	DB_NAME() AS DatabaseName
	, object_name(i.object_id) AS TableName
	, ISNULL(i.name, 'HEAP') AS IndexName
	, i.index_id AS IndexID
	, i.type_desc AS IndexType
	, p.partition_number AS PartitionNo
	, p.[rows] AS NumRows
	, au.type_desc AS InType
	, au.total_pages AS NumPages
	, au.total_pages * 8 AS TotKBs
	, au.used_pages * 8 AS UsedKBs
	, au.data_pages * 8 AS DataKBs
FROM sys.indexes i INNER JOIN sys.partitions p
ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units au ON
CASE
WHEN au.[type] in (1,3) THEN p.hobt_id
WHEN au.type = 2 THEN p.partition_id
end = au.container_id
INNER JOIN sys.objects o ON i.object_id = o.object_ido.is_ms_shipped <> 1
ORDER BY TableName, i.index_id;