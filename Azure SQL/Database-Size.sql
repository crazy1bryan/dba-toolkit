SELECT top 1 db_name() as DBName,
'SpacedUsedinMB' = cast(cast((cast(fileproperty(a.name, 'spaceused' )as int)/128.0) as numeric(15,2))as nvarchar),
'MaxSizeinMB' = (case maxsize when -1 then N'unlimited'  else cast(cast(maxsize as bigint) * 8 /1024 as nvarchar(15)) end)
, (cast(cast((cast(fileproperty(a.name, 'spaceused' )as int)/128.0) as numeric(15,2))as decimal))/((case maxsize when -1 then N'unlimited'  else cast(cast(maxsize as bigint) * 8 /1024 as decimal) end))* 100 as Percentvalue
from dbo.sysfiles a
LEFT join sys.filegroups fg
ON a.groupid = fg.data_space_id;

-- OR

SELECT SUM(reserved_page_count) * 8.0 / 1024 / 1024 AS DatabaseSizeGB FROM sys.dm_db_partition_stats;