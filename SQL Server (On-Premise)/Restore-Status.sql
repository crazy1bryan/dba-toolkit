SELECT
	d.name                                                                                                            AS DatabaseName,
	CONVERT(VARCHAR, CASE WHEN rh.stop_at < B. backup_finish_date THEN rh.stop_at ELSE b.backup_finish_date END)    AS RestoredTo,
	d.state_desc + CASE WHEN d.is_in_standby = 1 THEN ' (Standby)' ELSE '' END                                        AS State,
	d.user_access_desc                                                                                                AS UserAccess,
	d.recovery_model_desc                                                                                            AS RecoveryModel,
	b.server_name                                                                                                    AS SourceServer,
	b.database_name                                                                                                    AS SourceDatabase
FROM
	sys.databases d
	OUTER APPLY (SELECT TOP 1 backup_set_id, stop_at FROM msdb.dbo.restorehistory WHERE destination_database_name = d.name ORDER BY restore_history_id DESC) rh
	LEFT JOIN msdb.dbo.backupset b on b.backup_set_id = rh.backup_set_id
WHERE
	d.state            <> 0 OR
	d.user_access    <> 0
ORDER BY
	CASE WHEN rh.stop_at < B. backup_finish_date THEN rh.stop_at ELSE b.backup_finish_date END;