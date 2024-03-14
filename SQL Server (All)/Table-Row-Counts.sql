SELECT
	QUOTENAME(SCHEMA_NAME(so.schema_id)) + '.' + QUOTENAME(so.name) AS [TableName],
	FORMAT(SUM(sp.Rows), 'N0') AS [RowCount]
FROM sys.objects AS so
	INNER JOIN sys.partitions AS sp
		ON so.object_id = sp.object_id
WHERE
	so.type				= 'U' AND
	so.is_ms_shipped	= 0 AND
	sp.index_id			< 2		-- 0 = Heap, 1 = Clustered
GROUP BY
	so.schema_id,
	so.name
ORDER BY [TableName];