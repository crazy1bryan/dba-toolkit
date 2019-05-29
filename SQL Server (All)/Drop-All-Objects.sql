-- Run each query below, one at a time. Copy the results and paste them into another query window, then execute the statement(s).
 
-- Constraints
SELECT 'ALTER TABLE ' + SCHEMA_NAME(t.schema_id) + '.' + t.name + ' DROP CONSTRAINT ' + c.name
FROM sys.objects t INNER JOIN sys.objects c ON c.parent_object_id = t.object_id
WHERE t.type = 'U' AND c.type IN ('C', 'D', 'F', 'UQ');


-- Triggers
SELECT 'DROP TRIGGER ' + SCHEMA_NAME(schema_id) + '.' + name
FROM sys.objects
WHERE type = 'TR';


-- Views
SELECT 'DROP VIEW ' + SCHEMA_NAME(schema_id) + '.' + name
FROM sys.objects
WHERE type = 'V' AND SCHEMA_NAME(schema_id) <> 'sys';


-- Stored Procedures
SELECT 'DROP PROCEDURE ' + SCHEMA_NAME(schema_id) + '.' + name
FROM sys.objects
WHERE type = 'P';


-- Functions
SELECT 'DROP FUNCTION ' + SCHEMA_NAME(schema_id) + '.' + name
FROM sys.objects
WHERE type IN ('IF', 'TF');


-- Tables
SELECT 'DROP TABLE ' + SCHEMA_NAME(schema_id) + '.' + name
FROM sys.objects
WHERE type = 'U' AND name NOT IN ('Account', 'AuditEvents', 'Users');


-- Roles
SELECT 'DROP ROLE [' + name + '];'
FROM sysusers
WHERE issqlrole = 1 AND UID < 16384 AND name <> 'public';


-- Users
SELECT 'DROP USER [' + name + '];'
FROM sysusers
WHERE issqluser = 1 AND hasdbaccess = 1 AND name <> 'dbo';