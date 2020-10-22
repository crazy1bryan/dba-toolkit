DECLARE @IndexTargetDefinition TABLE
(
	column_name			SYSNAME			NOT NULL,
	is_included_column	BIT				NOT NULL,
	is_descending_key	BIT				NOT NULL,
	key_ordinal			TINYINT			NOT NULL,
	filter_definition	NVARCHAR(MAX)	NULL
)

DECLARE @IndexCurrentDefinition TABLE
(
	column_name			SYSNAME			NOT NULL,
	is_included_column	BIT				NOT NULL,
	is_descending_key	BIT				NOT NULL,
	key_ordinal			TINYINT			NOT NULL,
	filter_definition	NVARCHAR(MAX)	NULL
)

DECLARE
	@Edition	NVARCHAR(128),
	@table_name SYSNAME,
	@index_name SYSNAME,
	@Except1	TINYINT,
	@Except2	TINYINT;

SET @table_name = 'TableNameHere';
SET @index_name = 'IndexNameHere';

-- Define the target index definition (below is an example that will need to be modified with the correct values)
INSERT INTO @IndexTargetDefinition
VALUES
	('Column1', 0, 0, 1, NULL),
	('Column2', 0, 0, 2, NULL),
	('Column3', 0, 0, 3, NULL)

-- Retrieve the current index definition
INSERT INTO @IndexCurrentDefinition
SELECT
	col.name,
	ic.is_included_column,
	ic.is_descending_key,
	ic.key_ordinal,
	i.filter_definition
FROM sys.indexes i
	INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	INNER JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
	INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE
	t.name = @table_name AND
	i.name = @index_name

-- Find any differences between the current and target definitions
SELECT @Except1 = COUNT(*) FROM (
	SELECT
		column_name,
		is_included_column,
		is_descending_key,
		key_ordinal,
		filter_definition
	FROM @IndexCurrentDefinition

	EXCEPT

	SELECT
		column_name,
		is_included_column,
		is_descending_key,
		key_ordinal,
		filter_definition
	FROM @IndexTargetDefinition
) AS CountExcept1

-- Find any differences between the current and target definitions (reversed order)
SELECT @Except2 = COUNT(*) FROM (
	SELECT
		column_name,
		is_included_column,
		is_descending_key,
		key_ordinal,
		filter_definition
	FROM @IndexTargetDefinition

	EXCEPT

	SELECT
		column_name,
		is_included_column,
		is_descending_key,
		key_ordinal,
		filter_definition
	FROM @IndexCurrentDefinition
) AS CountExcept2

IF @Except1 > 0 OR @Except2 > 0
	BEGIN
		PRINT 'Current definition is different than the target. Drop and re-create'
	END;
ELSE
	BEGIN
		PRINT 'Current matches the target. No changes necessary'
	END;