SELECT
	CONCAT('SELECT ''', table_name, ''' AS table_name', ' , COUNT(*) AS Rows FROM [', schema_name, '].[', table_name,
	'] LEFT JOIN [', schema_name, '].[', referenced_table_name, '] ON [', schema_name, '].[', table_name, '].[', column_name, '] = [', schema_name, '].[', referenced_table_name, '].[', referenced_column_name,
	'] WHERE [', schema_name, '].[', referenced_table_name, '].[', referenced_column_name, '] IS NULL AND [', schema_name, '].[', table_name, '].[', column_name, '] IS NOT NULL UNION ')
FROM
	(SELECT
		obj.name AS [fk_name],
		sch.name AS [schema_name],
		tab1.name AS [table_name],
		col1.name AS [column_name],
		tab2.name AS [referenced_table_name],
		col2.name AS [referenced_column_name]
	FROM sys.foreign_key_columns fkc
		INNER JOIN sys.objects obj ON obj.object_id = fkc.constraint_object_id
		INNER JOIN sys.tables tab1 ON tab1.object_id = fkc.parent_object_id
		INNER JOIN sys.schemas sch ON tab1.schema_id = sch.schema_id
		INNER JOIN sys.columns col1 ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
		INNER JOIN sys.tables tab2 ON tab2.object_id = fkc.referenced_object_id
		INNER JOIN sys.columns col2 ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id
	) AS mytable
WHERE schema_name = 'dbo';