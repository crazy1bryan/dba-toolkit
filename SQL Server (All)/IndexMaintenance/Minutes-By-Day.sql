SELECT
	CAST(StartTime AS DATE),
	MIN(StartTime),
	MAX(EndTime),
	DATEDIFF(MINUTE, MIN(StartTime), MAX(EndTime)) AS Minutes
FROM
	dbo.CommandLog
GROUP BY
	CAST(StartTime AS DATE)
ORDER BY
	CAST(StartTime AS DATE)