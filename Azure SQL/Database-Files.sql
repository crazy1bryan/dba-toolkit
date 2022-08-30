-- For Hyperscale, this shows how many page servers we have
SELECT
	file_id,
	type_desc,
	name,
	size * 8 / (1024.0 * 1024.0) as SizeGB,
	max_size * 8 / (1024.0 * 1024.0) as MaxSizeGB
FROM
	sys.database_files
WHERE
	type_desc IN ('ROWS', 'LOG');