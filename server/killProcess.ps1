<######################################

Simple script to kill any stuck processes on a windows server using a specific port to create a valid PS Session.
Useful when a process is stuck and/or we need to ensure a processes is stopped 

Example: 

.\killProcess.ps1 -serverName $serverName -serverPort $serverPort -processName $processName -userName $userName -password $password 

######################################>

param(
	$serverName,
	$serverPort,
	$processName,
	$userName,
	$password
)

$pass = ConvertTo-SecureString -AsPlainText $password -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $pass

Write-Host "Creating Remote PowerShell Session, using $userName user name to connect to $serverName on port $serverPort"
try{
$session = New-PSSession -ComputerName $serverName -Credential $cred -Port $serverPort -SessionOption (New-PSSessionOption -ProxyAccessType NoProxyServer)
}
catch{
Write-Host $_}

Write-Host "Killing the $processName process on $serverName"

$checkProcess = Invoke-Command -Session $Session -Scriptblock {Get-Process -Name $using:processName -ea SilentlyContinue}

if($checkProcess -eq $Null){
	Write-Host "$processName currently not running on $serverName"
}
else{
	Write-Host "$processName currently running on $serverName. Stopping process."
	Invoke-Command -Session $Session -Scriptblock {Stop-Process -Name $using:processName -Force}
	Start-Sleep -s 15
}
