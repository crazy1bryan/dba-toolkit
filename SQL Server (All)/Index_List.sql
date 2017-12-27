SELECT
	SO.name,
	SI.name,
	*
FROM
	sys.indexes SI
	INNER JOIN sys.objects SO ON SO.object_id = SI.object_id
WHERE
	SO.is_ms_shipped = 0 AND
	SO.name NOT LIKE '%sysdiag%'
ORDER BY
	SO.name,
	SI.name;