-- Shown for current database user
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');

-- Show for another user
EXECUTE AS USER = 'UserHere';
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');
REVERT;