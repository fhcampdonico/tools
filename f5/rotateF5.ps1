<#######################################

This script can be used to enable and disable F5 pool members from a local PS session. 
Useful when running it from a CI/CD pipeline when it's a deployment requires to disable a node,
deploy code, then re-enable such node to ensure no traffic is being routed to it during deployment.

Example: 

.\RotateF5.ps1 -myLTM_IP $myLTM_IP -poolMember $poolMember -poolName $poolName -userName $userName -password $password -operation $operation

Pre-reqs:

1. This task required the F5-LTM module to be installed on the server. The module can be found under:
  https://devcentral.f5.com/s/articles/powershell-module-for-the-f5-ltm-rest-api
2. Script uses account with access to disable/enable nodes in F5.

#######################################>

param(
	$myLTM_IP,
	$poolMember,
	$poolName,
	$userName,
	$password,
	$operation
)

Import-Module F5-LTM

Write-Host "Creating Remote PowerShell Session to F5"
Write-Host "Local Traffic Manager (LTM) IP: $myLTM_IP"
Write-Host "Local Traffic Manager Service Account: $userName"

$pass = ConvertTo-SecureString -AsPlainText $password -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $pass
$F5Session = New-F5Session -LTMName $MyLTM_IP -LTMCredentials $cred -PassThrough

if($operation -eq "Disable"){
    Write-Host "Disabling F5 Pool Member $poolMember in $poolName"
    Disable-PoolMember -PoolName $poolName -Name $poolMember -F5Session $F5Session -Force
    Write-Host "Current F5 Status for $poolMember in $poolName"
    Get-PoolMember -F5Session $F5Session -Name $poolMember
}
elseif($operation -eq "Enable"){
    Write-Host "Enabling F5 Pool Member $poolMember in $poolName"
    Enable-PoolMember -PoolName $poolName -Name $poolMember -F5Session $F5Session
    Write-Host "Current F5 Status for $poolMember in $poolName"
    Get-PoolMember -F5Session $F5Session -Name $poolMember
}
elseif($operation -eq "Status"){
    Write-Host "Current F5 Status for $poolMember in $poolName"
    Get-PoolMember -F5Session $F5Session -Name $poolMember
}
else{
    Write-Host "Invalid Operation. Exiting"
    Exit -1
}


