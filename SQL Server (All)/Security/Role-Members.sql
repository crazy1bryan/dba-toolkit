SELECT
	r.name    AS RoleName,
	m.name    AS MemberName
FROM
	sys.database_role_members rm
	INNER JOIN sys.database_principals r on rm.role_principal_id = r.principal_id
	INNER JOIN sys.database_principals m on rm.member_principal_id = m.principal_id
ORDER BY
	r.name,
	m.name;