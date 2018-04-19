Add-AzureRmAccount

Set-AzureRmContext -SubscriptionID [SubscriptionID]

$PrimaryResourceGroupName = ""
$PrimaryServerName = ""
$SecondaryResourceGroupName = ""
$SecondaryServerName = ""
$FailoverGroupName = ""
$DatabaseName = ""

# Create the failover group
$FailoverGroup = New-AzureRMSqlDatabaseFailoverGroup `
	–ResourceGroupName $PrimaryResourceGroupName `
	-ServerName $PrimaryServerName `
	–PartnerResourceGroupName $SecondaryResourceGroupName `
	-PartnerServerName $SecondaryServerName `
	–FailoverGroupName $FailoverGroupName `
	–FailoverPolicy Automatic `
	-GracePeriodWithDataLossHours 1
$FailoverGroup

# Add a database to failover group
$FailoverGroup = Get-AzureRmSqlDatabase `
   -ResourceGroupName $PrimaryResourceGroupName `
   -ServerName $PrimaryServerName `
   -DatabaseName $DatabaseName | `
   Add-AzureRmSqlDatabaseToFailoverGroup `
   -ResourceGroupName $PrimaryResourceGroupName `
   -ServerName $PrimaryServerName `
   -FailoverGroupName $FailoverGroupName
$FailoverGroup


# Remove the failover group
Remove-AzureRMSqlDatabaseFailoverGroup `
	–ResourceGroupName $PrimaryResourceGroupName `
	-ServerName $PrimaryServerName `
	–FailoverGroupName $FailoverGroupName
$FailoverGroup

# Initiate a planned failover
Switch-AzureRMSqlDatabaseFailoverGroup `
   -ResourceGroupName $SecondaryResourceGroupName `
   -ServerName $SecondaryServerName `
   -FailoverGroupName $FailoverGroupName

# Initiate a planned fail back
Switch-AzureRMSqlDatabaseFailoverGroup `
   -ResourceGroupName $PrimaryResourceGroupName `
   -ServerName $PrimaryServerName `
   -FailoverGroupName $FailoverGroupName

# Monitor Geo-Replication config and health after failover
Get-AzureRMSqlDatabaseFailoverGroup `
   -ResourceGroupName $PrimaryResourceGroupName `
   -ServerName $PrimaryServerName

Get-AzureRMSqlDatabaseFailoverGroup `
   -ResourceGroupName $SecondaryResourceGroupName `
   -ServerName $SecondaryServerName