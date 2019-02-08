/*
	Run this script to get an overview of a database...
		- How many tables are there?
		- Are they wide or narrow (many or few columns)?
		- Are they grouped into multiple schemas?
		- What data types are in use?
			Legacy types like IMAGE and TEXT?
			Newer types like XML or Spatial?
			Are columns wide or narrow (NVARCHAR(MAX), BIGINT vs CHAR(1), TINYINT)?
		- How are tables and columns named?
			CamelBack, UPPER_CASE, lower_case?  All of the above?
			Is naming consistent across tables?
		- Is the design normalized or do the same columns show up in multiple tables?
		- Do related columns have the same data type throughout the database?
*/

SELECT   SCHEMA_NAME( t.schema_id ) + '.' + t.name AS table_name, c.name AS column_name,
         x.name
         + CASE WHEN c.system_type_id IN ( 165, 167, 175, 231, 239 ) THEN
                    '(' + REPLACE( CAST(c.max_length AS VARCHAR(4)), '-1', 'max' ) + ')'
               WHEN c.system_type_id IN ( 41, 42, 43 ) THEN '(' + CAST(c.scale AS VARCHAR(1)) + ')'
               WHEN c.system_type_id IN ( 106, 108 ) THEN
                   '(' + CAST(c.precision AS VARCHAR(2)) + ',' + CAST(c.scale AS VARCHAR(2)) + ')'
               ELSE ''
           END AS data_type,
         CASE c.is_identity WHEN 0 THEN '' WHEN 1 THEN 'Identity' END AS [identity],
         CASE c.is_nullable WHEN 0 THEN '' WHEN 1 THEN 'Nullable' END AS nullable,
         COALESCE( d.definition, '' ) AS default_value, COALESCE( cc.definition, '' ) AS computed
FROM     sys.tables t
         INNER JOIN sys.columns c ON c.object_id = t.object_id
         INNER JOIN sys.types x ON x.system_type_id = c.system_type_id
                                   AND x.user_type_id = c.user_type_id
         LEFT OUTER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
         LEFT OUTER JOIN sys.computed_columns cc ON cc.object_id = c.object_id AND cc.column_id = c.column_id
--WHERE t.object_id = OBJECT_ID(N'Production.TransactionHistory')
ORDER BY SCHEMA_NAME( t.schema_id ) + '.' + t.name, c.column_id;
