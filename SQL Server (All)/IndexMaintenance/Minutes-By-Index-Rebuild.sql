SELECT
	StartTime,
	EndTime,
	DATEDIFF(MINUTE, StartTime, EndTime) AS Minutes,
	ObjectName,
	IndexName
FROM
	dbo.CommandLog
WHERE
	StartTime >= CAST(GETDATE() AS DATE) AND
	CommandType	= 'ALTER_INDEX'
ORDER BY
	StartTime;