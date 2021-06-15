-- Shown for current database user
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');

-- Show for another user
EXECUTE AS USER = 'UserHere';
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');
REVERT;

-- Show all database-level permissions for all users
SELECT
	su.name,
	dp.state_desc,
	dp.permission_name
FROM sys.database_permissions dp
	INNER JOIN sysusers su on su.uid = dp.grantee_principal_id
WHERE
	dp.class = 0
ORDER BY
	su.name,
	dp.state_desc;