IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE Type = 'U' AND SCHEMA_NAME(schema_id) = 'dbo' AND name = 'MyTableName')
BEGIN
    CREATE TABLE [dbo].[MyTableName]
    (
        [ID] [int] IDENTITY(1,1) NOT NULL
    );
END;