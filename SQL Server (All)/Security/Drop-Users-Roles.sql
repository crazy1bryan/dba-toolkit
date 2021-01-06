-- Drop all users
DECLARE @SQL NVARCHAR(MAX) = '';
SET @SQL = '';

SELECT @SQL = @SQL + 'DROP USER [' + name + '];'
FROM dbo.sysusers
WHERE
	name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys', 'public') AND
	name NOT LIKE 'db_%' AND
	issqlrole = 0;

-- Drop all roles
EXECUTE sp_executesql @sql;

SET @SQL = '';
SELECT @SQL = @SQL + 'DROP ROLE [' + name + '];'
FROM dbo.sysusers
WHERE
	name <> 'public' AND
	name NOT LIKE 'db_%' AND
	issqlrole	= 1;
EXECUTE sp_executesql @sql;