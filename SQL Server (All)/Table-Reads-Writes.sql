-- This provides cumulative reads for a table at a point in time
-- A SQL server restart will reset the numbers to 0
-- An index DROP/RECREATE will reset the numbers for just that underlying index to 0
SELECT
	OBJECT_NAME(s.object_id)					AS TableName,
	SUM(user_seeks + user_scans + user_lookups)	AS Reads,
	SUM(user_updates)							AS Writes
FROM sys.dm_db_index_usage_stats AS s
	INNER JOIN sys.indexes AS i
		ON s.object_id = i.object_id AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
GROUP BY OBJECT_NAME(s.object_id)
ORDER BY TableName