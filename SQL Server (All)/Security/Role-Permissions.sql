SELECT
	dpr.[name]				AS 'PrincipalName',
	dpr.[type_desc]			AS 'PrincipalType',
	dpr2.[name]				AS 'GrantedBy',
	dp.[permission_name],
	dp.[state_desc],
	o.[Name]				AS 'ObjectName',
	o.[type_desc]			AS 'ObjectType'
FROM [sys].[database_permissions] dp
	LEFT JOIN [sys].[objects] o					ON dp.[major_id] = o.[object_id]
	LEFT JOIN [sys].[database_principals] dpr	ON dp.[grantee_principal_id] = dpr.[principal_id]
	LEFT JOIN [sys].[database_principals] dpr2	ON dp.[grantor_principal_id] = dpr2.[principal_id];