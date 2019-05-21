-- Objects used in Data Sync cannot contain certain characters
SELECT
    table_schema,
    table_name,
    column_name
FROM information_schema.columns
WHERE
    table_name LIKE '%.%' OR
    table_name LIKE '%[[]%' OR
    table_name LIKE '%]%' OR
    column_name LIKE '%.%' OR
    column_name LIKE '%[[]%' OR
    column_name LIKE '%]%';