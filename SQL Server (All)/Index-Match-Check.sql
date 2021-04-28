/*
We had a case where the definitions of some indexes were out of sync between databases.
That is, they had the same name in all databases, but there were underlying definition differences between databases.
As some of the indexes are very large and it is a heavily-used system,
we could not simply drop and re-create the indexes in question to ensure that the definitions matched.
We needed a script that would only drop and re-create indexes with incorrect definitions.
The deployment script needed the ability to be executed on all databases and use the following process:
	* Compare the index to the target definition
	* If the index matches the target definition, do nothing
	* If the index does not match the target definition, drop and re-create the index

The script below can be used to change (drop and re-create) an existing index to match a target definition.
Note the TODO sections where you will need to fill in the details for the index.
Please also note that this does not cover all difference scenarios.
It was designed only to cover the differences being experienced when the script was created.
*/

DECLARE @IndexTargetDefinition TABLE
(
	column_name			SYSNAME			NOT NULL,
	is_included_column	BIT				NOT NULL,
	is_descending_key	BIT				NOT NULL,
	key_ordinal			TINYINT			NOT NULL,
	filter_definition	NVARCHAR(MAX)	NULL
);

DECLARE @IndexCurrentDefinition TABLE
(
	column_name			SYSNAME			NOT NULL,
	is_included_column	BIT				NOT NULL,
	is_descending_key	BIT				NOT NULL,
	key_ordinal			TINYINT			NOT NULL,
	filter_definition	NVARCHAR(MAX)	NULL
);

DECLARE
	@Edition	NVARCHAR(128),
	@table_name SYSNAME,
	@index_name SYSNAME,
	@Except1	TINYINT,
	@Except2	TINYINT;

-- TODO: Substitute the table and index name here
SET @table_name = 'TableName';
SET @index_name = 'IndexName';

-- TODO: Setup the definitions for the target index columns and state
INSERT INTO @IndexTargetDefinition
VALUES
	('Column1', 0, 0, 1, NULL),
	('Column2', 0, 0, 2, NULL),
	('Column3', 0, 0, 3, NULL);

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
	i.name = @index_name;

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
) AS CountExcept1;

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
) AS CountExcept2;

IF @Except1 > 0 OR @Except2 > 0
	BEGIN
		-- TODO: Add T-SQL to drop and create the index
		PRINT 'Current definition is different than the target. Drop and re-create'
	END;
ELSE
	BEGIN
		PRINT 'Current matches the target. No changes necessary'
	END;