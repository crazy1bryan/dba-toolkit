$Logfile = "C:\Windows\Temp\LoginTest.log"
while (1 -eq 1) {
	$Date = Get-Date -Format o
	$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
	$login = osql -S "[ServerName].database.windows.net" -U "[Username]" -Q "SELECT 1;" -d "[DatabaseName]" -P "[Password]"
	$stopwatch.Stop()
	$Milliseconds = $stopwatch.ElapsedMilliseconds
	Add-content $Logfile -value "$Date   $Milliseconds   $login"
}