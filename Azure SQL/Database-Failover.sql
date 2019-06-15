-- Execute ONE of the command below in the master database of the SQL Server that is to become the new primary

-- In an unplanned fail over (where the primary is not available), execute this:
ALTER DATABASE [NuanceMC] FORCE_FAILOVER_ALLOW_DATA_LOSS;
 
-- OR
 
-- In an planned fail over (where the primary is available), execute this:
ALTER DATABASE [NuanceMC] FAILOVER;