DECLARE @SQL NVARCHAR(MAX) = '';

SET @SQL = N'';

SELECT @SQL = @SQL + 'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) +';'
FROM sys.views
WHERE is_ms_shipped = 0;

EXECUTE sys.sp_executesql @SQL;