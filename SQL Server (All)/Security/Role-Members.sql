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

Thursday 7:30am - 2:16  10
6pm - 9pm


Friday    5hours
Saturday 4 hours
	
Monday 6:48am - 5:30pm      11 hours
9:03pm

Tuesday 7:46am - 2:50pm     7 hours

Wednesday 5:22am - 2:22pm   11 hours
10:07 - midnight            

Thursday 1:07am - 3:30 am  9.5 hours
8:30am - 12:30pm           
1:30pm - 3:30pm            

