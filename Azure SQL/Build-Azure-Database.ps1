Param(
	[string]$subscriptionID,					# Required
	[string]$keyVault,							# Required
	[string]$administratorLogin,				# Required
	[string]$installLogin,						# Required
	[string]$applicationLogin,					# Required
	[string]$monitorLogin,						# Optional
	[string]$primaryResourceGroup,				# Required
	[string]$primaryLocation,					# Required
	[string]$primaryServer,						# Required
	[string]$databaseName,						# Required
	[string]$maxSizeBytes,						# Required
	[string]$primaryEdition,					# Required
	[string]$primaryServiceObjective,			# Required
	[string]$secondaryResourceGroup,			# Optional
	[string]$secondaryLocation,					# Optional
	[string]$secondaryServer,					# Optional
	[string]$secondaryEdition,					# Optional
	[string]$secondaryServiceObjective,			# Optional
	[string]$backupRetentionDays = 35,			# Optional, Values: 7, 14, 21, 28, 35
	[string]$readScale = "Disabled",			# Optional, Values: Disabled, Enabled
	[bool]$zoneRedundant = $true,				# Optional
	[bool]$enableAutomaticTuning = $true,		# Optional
	[string]$cloud = "COMMERCIAL"				# Optional, Values: COMMERCIAL, USGOVERNMENT
)

# Prerequisites
#	* An Azure subscription
#	* A Key Vault with the administrator, installer, and application credentials created

# Construct fully-qualified server names
$cloudDomain = switch ($cloud) {
	"COMMERCIAL" {"database.windows.net"}
	"USGOVERNMENT" {"database.usgovcloudapi.net"}
}
$primaryServer_FQ = $primaryServer + "." + $cloudDomain
$secondaryServer_FQ = $secondaryServer + "." + $cloudDomain

# Set the subscriptionID
Set-AzContext -SubscriptionId $subscriptionID

# Obtain necessary credentials
$administratorCredential = $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $administratorLogin, $(ConvertTo-SecureString -String (Get-AzKeyVaultSecret -vaultName $keyVault -name $administratorLogin).SecretValueText -AsPlainText -Force))
$administratorPassword = $(Get-AzKeyVaultSecret -vaultName $keyVault -name $administratorLogin).SecretValueText
$InstallPassword = $(Get-AzKeyVaultSecret -vaultName $keyVault -name $installLogin).SecretValueText
$applicationPassword = $(Get-AzKeyVaultSecret -vaultName $keyVault -name $applicationLogin).SecretValueText
if (-NOT [string]::IsNullOrWhiteSpace($monitorLogin)) {
	$monitorPassword = $(Get-AzKeyVaultSecret -vaultName $keyVault -name $monitorLogin).SecretValueText
}

# Create primary resource group
#Enable-AzAlias
New-AzResourceGroup `
	-Name $primaryResourceGroup `
	-Location $primaryLocation `
	-Force

# Create primary SQL Server
$primaryServerInstance = Get-AzSqlServer `
	-ServerName $primaryServer `
	-ResourceGroupName $primaryResourceGroup `
	-ErrorAction SilentlyContinue
If (-NOT $primaryServerInstance)
{
	New-AzSqlServer `
		-ResourceGroupName $primaryResourceGroup `
		-Location $primaryLocation `
		-ServerName $primaryServer `
		-SqlAdministratorCredentials $administratorCredential
}

# Set firewall rules
$primaryFirewallRule = Get-AzSqlServerFirewallRule -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -FirewallRuleName "AllowAllAzureIPs" -ErrorAction Ignore
If (-NOT $primaryFirewallRule)
{
	New-AzSqlServerFirewallRule -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -AllowAllAzureIPs
}

# Create primary database
$primaryDatabase = Get-AzSqlDatabase `
	-ResourceGroupName $primaryResourceGroup `
	-ServerName $primaryServer `
	-DatabaseName $databaseName `
	-ErrorAction SilentlyContinue
If (-NOT $primaryDatabase)
{
	New-AzSqlDatabase `
		-ResourceGroupName $primaryResourceGroup `
		-ServerName $primaryServer `
		-DatabaseName $databaseName `
		-Edition $primaryEdition `
		-RequestedServiceObjectiveName $primaryServiceObjective `
		-MaxSizeBytes $maxSizeBytes
}

# Set primary database options
If ($zoneRedundant) {
	Set-AzSqlDatabase -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -DatabaseName $databaseName -ZoneRedundant -ReadScale $readScale
} else {
	Set-AzSqlDatabase -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -DatabaseName $databaseName -ReadScale $readScale
}

# Configure automatic tuning
If ($enableAutomaticTuning) {
	Invoke-Sqlcmd -Query "ALTER DATABASE [$databaseName] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);" `
		-ServerInstance $primaryServer_FQ `
		-Database "master" `
		-Username $administratorLogin `
		-Password $administratorPassword
} else {
	Invoke-Sqlcmd -Query "ALTER DATABASE [$databaseName] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF);" `
		-ServerInstance $primaryServer_FQ `
		-Database "master" `
		-Username $administratorLogin `
		-Password $administratorPassword
}

# Set the backup retention policy
Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $primaryResourceGroup -ServerName $primaryServer -DatabaseName $databaseName -RetentionDays $backupRetentionDays

if (-NOT [string]::IsNullOrWhiteSpace($secondaryResourceGroup)) {

	# Create secondary resource group
	New-AzResourceGroup `
		-Name $secondaryResourceGroup `
		-Location $secondaryLocation `
		-Force

	# Create secondary SQL Server
	$secondaryServerInstance = Get-AzSqlServer `
		-ServerName $secondaryServer `
		-ResourceGroupName $secondaryResourceGroup `
		-ErrorAction SilentlyContinue
	If (-NOT $secondaryServerInstance)
	{
		New-AzSqlServer `
			-ResourceGroupName $secondaryResourceGroup `
			-Location $secondaryLocation `
			-ServerName $secondaryServer `
			-SqlAdministratorCredentials $administratorCredential

		New-AzSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -AllowAllAzureIPs
	}

	# Set firewall rules
	$secondaryFirewallRule = Get-AzSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -FirewallRuleName "AllowAllAzureIPs"
	If (-NOT $secondaryFirewallRule)
	{
		New-AzSqlServerFirewallRule -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -AllowAllAzureIPs
	}

	# Create geo-replica database
	$secondaryDatabase = Get-AzSqlDatabase `
		-ResourceGroupName $secondaryResourceGroup `
		-ServerName $secondaryServer `
		-DatabaseName $databaseName `
		-ErrorAction SilentlyContinue
	If (-NOT $secondaryDatabase) {
		New-AzSqlDatabaseSecondary `
			-ResourceGroupName $primaryResourceGroup `
			-ServerName $primaryServer `
			-DatabaseName $databaseName `
			-PartnerResourceGroupName $secondaryResourceGroup `
			-PartnerServerName $secondaryServer `
			-AllowConnections "All"
	}

	# Set secondary database options
	If ($zoneRedundant) {
		Set-AzSqlDatabase -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -DatabaseName $databaseName -ZoneRedundant -ReadScale $readScale
	} else {
		Set-AzSqlDatabase -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -DatabaseName $databaseName -ReadScale $readScale
	}

	# Set the backup retention policy
	Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $secondaryResourceGroup -ServerName $secondaryServer -DatabaseName $databaseName -RetentionDays $backupRetentionDays
}

# Installation login, user, and permission
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$installLogin') CREATE LOGIN [$installLogin] WITH PASSWORD = '$InstallPassword';" `
	-ServerInstance $primaryServer_FQ `
	-Database "master" `
	-Username $administratorLogin `
	-Password $administratorPassword

Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sysusers WHERE name = '$installLogin') CREATE USER [$installLogin] FOR LOGIN [$installLogin] ELSE ALTER USER [$installLogin] WITH LOGIN = [$installLogin];" `
	-ServerInstance $primaryServer_FQ `
	-Database $databaseName `
	-Username $administratorLogin `
	-Password $administratorPassword

Invoke-Sqlcmd -Query "GRANT EXECUTE TO [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "GRANT VIEW DEFINITION TO [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "GRANT IMPERSONATE ON USER::dbo TO [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "ALTER ROLE [db_ddladmin] ADD MEMBER [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "ALTER ROLE [db_datareader] ADD MEMBER [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "ALTER ROLE [db_datawriter] ADD MEMBER [$installLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword


# Application login, user, and permissions
Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$applicationLogin') CREATE LOGIN [$applicationLogin] WITH PASSWORD = '$applicationPassword';" `
	-ServerInstance $primaryServer_FQ `
	-Database "master" `
	-Username $administratorLogin `
	-Password $administratorPassword

Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sysusers WHERE name = '$applicationLogin') CREATE USER [$applicationLogin] FOR LOGIN [$applicationLogin] ELSE ALTER USER [$applicationLogin] WITH LOGIN = [$applicationLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
Invoke-Sqlcmd -Query "GRANT EXECUTE TO [$applicationLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword

# Monitor login, user, and permissions
if (-NOT [string]::IsNullOrWhiteSpace($monitorLogin)) {
	Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$monitorLogin') CREATE LOGIN [$monitorLogin] WITH PASSWORD = '$monitorPassword';" `
		-ServerInstance $primaryServer_FQ `
		-Database "master" `
		-Username $administratorLogin `
		-Password $administratorPassword

	Invoke-Sqlcmd -Query "IF NOT EXISTS (SELECT 1 FROM sysusers WHERE name = '$monitorLogin') CREATE USER [$monitorLogin] FOR LOGIN [$monitorLogin] ELSE ALTER USER [$monitorLogin] WITH LOGIN = [$monitorLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
	Invoke-Sqlcmd -Query "GRANT VIEW DATABASE STATE TO [$monitorLogin];" -ServerInstance $primaryServer_FQ -Database $databaseName -Username $administratorLogin -Password $administratorPassword
}

# Create the secondary database if requested
If (-NOT [string]::IsNullOrWhiteSpace($secondaryResourceGroup)) {
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

	# Monitor login on secondary
	if (-NOT [string]::IsNullOrWhiteSpace($monitorLogin)) {
		$monitorSID =
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

		SET @SID_varbinary = (SELECT SID FROM sys.sql_logins WHERE name = '$monitorLogin');
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

		Invoke-Sqlcmd -Query "IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$($monitorLogin)') DROP LOGIN [$monitorLogin] CREATE LOGIN [$monitorLogin] WITH PASSWORD = '$monitorPassword', SID = $monitorSID;" -ServerInstance $secondaryServer_FQ -Database "master" -Username $administratorLogin -Password $administratorPassword
	}
}