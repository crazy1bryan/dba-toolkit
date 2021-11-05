-- Create Index (ONLINE)
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IndexName' AND object_id = OBJECT_ID('[dbo].[TableName]'))
BEGIN
	DECLARE @Edition NVARCHAR(128);
	SET @Edition = CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128));

	IF (CHARINDEX('Azure', @Edition) > 0) OR (CHARINDEX('Enterprise', @Edition) > 0)
		BEGIN
			EXECUTE sp_executesql N'';
		END;
	ELSE
		BEGIN
			EXECUTE sp_executesql N'';
		END;
END;

-- Create Index (OFFLINE)
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IndexName' AND object_id = OBJECT_ID('[dbo].[TableName]'))
BEGIN
	EXECUTE sp_executesql N'';
END;

-- Replace Index
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IndexName' AND object_id = OBJECT_ID('[dbo].[TableName]'))
BEGIN
	DECLARE @Edition NVARCHAR(128);
	SET @Edition = CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128));

	IF (CHARINDEX('Azure', @Edition) > 0) OR (CHARINDEX('Enterprise', @Edition) > 0)
		BEGIN
			EXECUTE sp_executesql N'';
		END;
	ELSE
		BEGIN
			EXECUTE sp_executesql N'';
		END;

	IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IndexName' AND object_id = OBJECT_ID('[dbo].[TableName]'))
	BEGIN
		DROP INDEX [dbo].[TableName].[IndexName];
	END;

	EXEC sp_rename '[TableName].IndexName_NEW', 'IndexName'
END;

-- Drop Index
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IndexName' AND object_id = OBJECT_ID('[dbo].[TableName]'))
BEGIN
	DROP INDEX [dbo].[TableName].[IndexName];
END;
