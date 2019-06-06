Param(
	[string]$subscriptionID,
	[string]$keyVault,
	[string]$administratorLogin,
	[string]$installLogin,
	[string]$applicationLogin,
	[string]$primaryResourceGroup,
	[string]$primaryLocation,
	[string]$primaryServer,
	[string]$databaseName,
	[string]$maxSizeBytes,
	[string]$primaryEdition,
	[string]$primaryServiceObjective,
	[string]$secondaryResourceGroup,
	[string]$secondaryLocation,
	[string]$secondaryServer,
	[string]$secondaryEdition,
	[string]$secondaryServiceObjective
)

# Prerequisites
#	* An Azure subsciption
#	* A Key Vault with the administrator, installer, and application credentials created
#	* Manually create the administrator account on any existing SQL Servers that use the legacy administator account. For example:

$primaryServer_FQ = $primaryServer + ".database.windows.net"
$secondaryServer_FQ = $secondaryServer + ".database.windows.net"

# Set the subscriptionID
Set-AzureRmContext -SubscriptionId $subscriptionID

# Obtain necessary credentials
$administratorCredential = $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $administratorLogin, $(ConvertTo-SecureString -String (Get-AzureKeyVaultSecret -vaultName $keyVault -name $administratorLogin).SecretValueText -AsPlainText -Force))
$administratorPassword = $(Get-AzureKeyVaultSecret -vaultName $keyVault -name $administratorLogin).SecretValueText
$InstallCredential = $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $installLogin, $(ConvertTo-SecureString -String (Get-AzureKeyVaultSecret -vaultName $keyVault -name $installLogin).SecretValueText -AsPlainText -Force))
$InstallPassword = $(Get-AzureKeyVaultSecret -vaultName $keyVault -name $installLogin).SecretValueText
$applicationCredential = $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationLogin, $(ConvertTo-SecureString -String (Get-AzureKeyVaultSecret -vaultName $keyVault -name $applicationLogin).SecretValueText -AsPlainText -Force))
$applicationPassword = $(Get-AzureKeyVaultSecret -vaultName $keyVault -name $applicationLogin).SecretValueText

# Create primary resource group
New-AzureRmResourceGroup `
	-Name $primaryResourceGroup `
	-Location $primaryLocation `
	-Force

# Create primary SQL Server
$primaryServerInstance = Get-AzureRmSqlServer `
	-ServerName $primaryServer `
	-ResourceGroupName $primaryResourceGroup `
	-ErrorAction SilentlyContinue
If (-NOT $primaryServerInstance)
{
	New-AzureRmSqlServer `
		-ResourceGroupName $primaryResourceGroup `
		-Location $primaryLocation `
		-ServerName $primaryServer `
		-SqlAdministratorCredentials $administratorCredential
}

$primaryFirewallRule = Get-AzureRmSqlServerFirewallRule -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -FirewallRuleName "AllowAllAzureIPs"
If (-NOT $primaryFirewallRule)
{
	New-AzureRmSqlServerFirewallRule -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -AllowAllAzureIPs
}

# Create primary database
$primaryDatabase = Get-AzureRmSqlDatabase `
	-ResourceGroupName $primaryResourceGroup `
	-ServerName $primaryServer `
	-DatabaseName $databaseName `
	-ErrorAction SilentlyContinue
If (-NOT $primaryDatabase)
{
	New-AzureRmSqlDatabase `
		-ResourceGroupName $primaryResourceGroup `
		-ServerName $primaryServer `
		-DatabaseName $databaseName `
		-Edition $primaryEdition `
		-RequestedServiceObjectiveName $primaryServiceObjective `
		-MaxSizeBytes $maxSizeBytes
}

if (-NOT [string]::IsNullOrWhiteSpace($secondaryResourceGroup)) {

	# Create secondary resource group
	New-AzureRmResourceGroup `
		-Name $secondaryResourceGroup `
		-Location $secondaryLocation `
		-Force

	# Create secondary SQL Server
	$secondaryServerInstance = Get-AzureRmSqlServer `
		-ServerName $secondaryServer `
		-ResourceGroupName $secondaryResourceGroup `
		-ErrorAction SilentlyContinue
	If (-NOT $secondaryServerInstance)
	{
		New-AzureRmSqlServer `
			-ResourceGroupName $secondaryResourceGroup `
			-Location $secondaryLocation `
			-ServerName $secondaryServer `
			-SqlAdministratorCredentials $administratorCredential

		New-AzureRmSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -AllowAllAzureIPs
	}

	$secondaryFirewallRule = Get-AzureRmSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -FirewallRuleName "AllowAllAzureIPs"
	If (-NOT $secondaryFirewallRule)
	{
		New-AzureRmSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -AllowAllAzureIPs
	}

	# Create geo-replica database
	$secondaryDatabase = Get-AzureRmSqlDatabase `
		-ResourceGroupName $secondaryResourceGroup `
		-ServerName $secondaryServer `
		-DatabaseName $databaseName `
		-ErrorAction SilentlyContinue
	If (-NOT $secondaryDatabase)
	{
		New-AzureRmSqlDatabaseSecondary `
			-ResourceGroupName $primaryResourceGroup `
			-ServerName $primaryServer `
			-DatabaseName $databaseName `
			-PartnerResourceGroupName $secondaryResourceGroup `
			-PartnerServerName $secondaryServer `
			-AllowConnections "All"
	}
}

# Installation login
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$installLogin') CREATE LOGIN [$installLogin] WITH PASSWORD = '$InstallPassword';" -ServerInstance $primaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword

# Application login
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$applicationLogin') CREATE LOGIN [$applicationLogin] WITH PASSWORD = '$applicationPassword';" -ServerInstance $primaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword
 
# Installation user/permissions
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sysusers WHERE name = '$installLogin') CREATE USER [$installLogin] FOR LOGIN [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
 
Invoke-Sqlcmd -Query "GRANT EXECUTE TO [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "GRANT VIEW DEFINITION TO  [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
 
Invoke-Sqlcmd -Query "EXEC sp_addrolemember 'db_ddladmin', '$installLogin';" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "EXEC sp_addrolemember 'db_datareader', '$installLogin';" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "EXEC sp_addrolemember 'db_datawriter', '$installLogin';" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
 
# Application user/permissions 
Invoke-Sqlcmd -Query "IF EXISTS (SELECT 1 FROM sysusers WHERE name = '$applicationLogin') DROP USER [$applicationLogin] CREATE USER [$applicationLogin] FOR LOGIN [$applicationLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "GRANT EXECUTE TO [$applicationLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword

if (-NOT [string]::IsNullOrWhiteSpace($secondaryResourceGroup)) {
	# Installation login on secondary
	$InstallSID =
	(Invoke-Sqlcmd -Query "
	DECLARE
	  @SID_varbinary  VARBINARY(256),
	  @SID_string  VARCHAR(514) = '0x',
	  @i  SMALLINT = 1,
	  @length  SMALLINT,
	  @hexstring  CHAR(16) = '0123456789ABCDEF',
	  @tempint  SMALLINT,
	  @firstint  SMALLINT,
	  @secondint  SMALLINT;

	SET @SID_varbinary = (SELECT SID FROM sys.sql_logins WHERE name = '$installLogin');
	SET @length = DATALENGTH (@SID_varbinary);

	WHILE (@i <= @length)
	BEGIN
	  SET @tempint = CONVERT(INT, SUBSTRING(@SID_varbinary, @i, 1));
	  SET @firstint = FLOOR(@tempint / 16);
	  SET @secondint = @tempint - (@firstint * 16);
	  SET @SID_string = @SID_string +
		SUBSTRING(@hexstring, @firstint + 1, 1) +
		SUBSTRING(@hexstring, @secondint + 1, 1);
	  SET @i = @i + 1;
	END;

	SELECT @SID_string AS SID;
	" -ServerInstance $primaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword).SID

	Invoke-Sqlcmd -Query "IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$($installLogin)') DROP LOGIN [$installLogin] CREATE LOGIN [$installLogin] WITH PASSWORD = '$InstallPassword', SID = $InstallSID;" -ServerInstance $secondaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword

	# Application login on secondary
	$applicationSID =
	(Invoke-Sqlcmd -Query "
	DECLARE
	  @SID_varbinary  VARBINARY(256),
	  @SID_string  VARCHAR(514) = '0x',
	  @i  SMALLINT = 1,
	  @length  SMALLINT,
	  @hexstring  CHAR(16) = '0123456789ABCDEF',
	  @tempint  SMALLINT,
	  @firstint  SMALLINT,
	  @secondint  SMALLINT;

	SET @SID_varbinary = (SELECT SID FROM sys.sql_logins WHERE name = '$applicationLogin');
	SET @length = DATALENGTH (@SID_varbinary);

	WHILE (@i <= @length)
	BEGIN
	  SET @tempint = CONVERT(INT, SUBSTRING(@SID_varbinary, @i, 1));
	  SET @firstint = FLOOR(@tempint / 16);
	  SET @secondint = @tempint - (@firstint * 16);
	  SET @SID_string = @SID_string +
		SUBSTRING(@hexstring, @firstint + 1, 1) +
		SUBSTRING(@hexstring, @secondint + 1, 1);
	  SET @i = @i + 1;
	END;

	SELECT @SID_string AS SID;
	" -ServerInstance $primaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword).SID

	Invoke-Sqlcmd -Query "IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$($applicationLogin)') DROP LOGIN [$applicationLogin] CREATE LOGIN [$applicationLogin] WITH PASSWORD = '$applicationPassword', SID = $applicationSID;" -ServerInstance $secondaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword
}