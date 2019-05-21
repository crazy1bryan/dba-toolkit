-- Objects using Data Sync cannot have circular reference
SELECT
    OBJECT_SCHEMA_NAME(fk1.parent_object_id) + '.' + OBJECT_NAME(fk1.parent_object_id) Table1,
    OBJECT_SCHEMA_NAME(fk2.parent_object_id) + '.' + OBJECT_NAME(fk2.parent_object_id) Table2
FROM
    sys.foreign_keys AS fk1
        INNER JOIN sys.foreign_keys AS fk2
            ON fk1.parent_object_id = fk2.referenced_object_id AND
            fk2.parent_object_id = fk1.referenced_object_id
WHERE
    fk1.parent_object_id <> fk2.parent_object_id;