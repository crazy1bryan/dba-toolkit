SELECT
	ObjectName,
	IndexName,
	AVG(ExtendedInfo.value('ExtendedInfo[1]/Fragmentation[1]', 'REAL'))	AS FragmentationPercent,
	SUM(CASE WHEN Command LIKE '%REBUILD%' THEN 1 ELSE 0 END)			AS RebuildCount,
	SUM(CASE WHEN Command LIKE '%REORGANIZE%' THEN 1 ELSE 0 END)		AS ReorganizeCount,
	AVG(DATEDIFF(MINUTE, StartTime, EndTime))							AS AverageDurationMinutes,
	AVG(ExtendedInfo.value('ExtendedInfo[1]/PageCount[1]', 'INT'))		AS PageCount
FROM dbo.CommandLog
WHERE
	StartTime	>= '2018-08-28' AND
	CommandType	= 'ALTER_INDEX'
GROUP BY
	ObjectName,
	IndexName,
	Command
ORDER BY
	ObjectName,
	IndexName,
	Command