DECLARE @SQLString NVARCHAR(MAX);
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE Type = 'V' AND SCHEMA_NAME(schema_id) = 'dbo' AND name = 'MyViewName')
    BEGIN
        SET @SQLString = 'CREATE VIEW [MyViewName] AS SELECT 1 AS MyColumn;';
        EXECUTE (@SQLString);
    END;
ELSE
    BEGIN
        SET @SQLString = 'ALTER VIEW [MyViewName] AS
            -- body of view';
        EXECUTE (@SQLString);
    END;