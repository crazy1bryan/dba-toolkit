IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type = 'P' AND SCHEMA_NAME(schema_id) = 'dbo' AND  name = 'MyProcName')
BEGIN
    EXECUTE ('CREATE PROCEDURE [dbo].[MyProcName] AS SELECT 1');
END;
GO
 
ALTER PROCEDURE [dbo].[MyProcName]
AS
-- body of stored procedure