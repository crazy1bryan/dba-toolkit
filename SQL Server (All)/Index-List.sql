SELECT
	OBJECT_SCHEMA_NAME(i.[object_id]) AS SchemaName,
	OBJECT_NAME(i.[object_id]) AS TableName,
	i.[name] AS IndexName,
	c.[name] AS ColumnName,
	ic.is_included_column,
	i.index_id,
	i.type_desc,
	i.is_unique,
	i.data_space_id,
	i.ignore_dup_key,
	i.is_primary_key
FROM sys.indexes i
	INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND i.index_id = ic.index_id
	INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
ORDER BY
	SchemaName,
	TableName,
	ic.index_id,
	ic.index_column_id;