SELECT
	partner_server,
	partner_database,
	last_replication,
	replication_lag_sec
FROM
	sys.dm_geo_replication_link_status;