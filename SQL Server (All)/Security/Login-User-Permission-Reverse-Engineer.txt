-- Reverse-engineer login to be created on another server
SELECT 'CREATE LOGIN [' + name + '] WITH PASSWORD = '''';'
FROM sysusers
WHERE uid > 4 AND hasdbaccess = 1
ORDER BY name;

-- Reverse-engineer users to be created on another database
SELECT 'CREATE USER [' + name + '] FROM LOGIN  [' + name + '];'
FROM sysusers
WHERE uid > 4 AND hasdbaccess = 1
ORDER BY name;

-- Add a role for each user in the database
SELECT 'EXEC sp_addrolemember ''RoleName'', ''' + name + ''';'
FROM sysusers
WHERE uid > 4 AND hasdbaccess = 1
ORDER BY name;