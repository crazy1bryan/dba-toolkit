$ServerName = "server-name"
$DatabaseName = "database-name"
$ResourceGroupName = "resource-group"

Get-AzureRmSqlDatabaseActivity -ServerName $ServerName -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName

# Get the correction OperationId from above and fill it in below
Stop-AzureRmSqlDatabaseActivity -ServerName $ServerName -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName -OperationId "from-above-list"