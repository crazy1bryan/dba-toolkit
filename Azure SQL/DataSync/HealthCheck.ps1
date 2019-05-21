$parameters = @{
    ## Databases and credentials
    # Sync metadata database credentials (Only SQL Authentication is supported)
    SyncDbServer = '.database.windows.net'
    SyncDbDatabase = ''
    SyncDbUser = ''
    SyncDbPassword = ''
 
    # Hub credentials (Only SQL Authentication is supported)
    HubServer = '.database.windows.net'
    HubDatabase = ''
    HubUser = ''
    HubPassword = ''
 
    # Member credentials (Azure SQL DB or SQL Server)
    MemberServer = '.database.windows.net'
    MemberDatabase = ''
    MemberUser = ''
    MemberPassword = ''
    # set MemberUseWindowsAuthentication to $true in case you wish to use integrated Windows authentication (MemberUser and MemberPassword will be ignored)
    MemberUseWindowsAuthentication = $false
 
    ## Optional parameters (default values will be used if ommited)
 
    ## Health checks
    HealthChecksEnabled = $true  #Set as $true (default) or $false
 
    ## Monitoring
    MonitoringMode = 'AUTO'  #Set as AUTO (default), ENABLED or DISABLED
    MonitoringIntervalInSeconds = 20
    MonitoringDurationInMinutes = 2
 
    ## Tracking Record Validations
    ExtendedValidationsTableFilter = @('All')  #Set as "All" or the tables you need using '[dbo].[TableName1]','[dbo].[TableName2]'
    ExtendedValidationsEnabledForHub = $false  #Set as $true or $false (default)
    ExtendedValidationsEnabledForMember = $false  #Set as $true or $false (default)
    ExtendedValidationsCommandTimeout = 900 #seconds (default)
 
    ## Other
    SendAnonymousUsageData = $true  #Set as $true (default) or $false
    DumpMetadataSchemasForSyncGroup = '' #leave empty for automatic detection
    DumpMetadataObjectsForTable = '' #needs to be formatted like [SchemaName].[TableName]
}
 
$scriptUrlBase = 'https://raw.githubusercontent.com/Microsoft/AzureSQLDataSyncHealthChecker/master'
Invoke-Command -ScriptBlock ([Scriptblock]::Create((iwr ($scriptUrlBase+'/AzureSQLDataSyncHealthChecker.ps1')).Content)) -ArgumentList $parameters
