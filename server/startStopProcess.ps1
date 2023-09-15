<######################################

Simple script to stop or restart a process through a valid PS Session.

Example: 

.\StartStopServicesOnPremServers.ps1 -serverName $serverName -serverPort $serverPort -serviceName $serviceName -operation $operation -userName $userName -password $password 

######################################>

param(
	$serverName,
	$serverPort,
	$serviceName,
	$operation,
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

if($operation -eq "Start"){
    Write-Host "Starting $serviceName on $serverName"
	Invoke-Command -Session $Session -Scriptblock {Start-Service -DisplayName $using:serviceName}
	Start-Sleep -s 5
}

elseif($operation -eq "Stop"){
	Write-Host "Stopping $serviceName on $serverName"
    Invoke-Command -Session $Session -Scriptblock {Stop-Service -DisplayName $using:serviceName}
	Start-Sleep -s 5
}

else{
	Write-Host "Invalid $operation. Exiting"
	Exit -1
}
