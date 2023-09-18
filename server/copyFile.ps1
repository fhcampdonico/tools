<######################################

Simple script to copy a single file from one server to another by creating a valid PS Session.

Example: 

.\copyFile.ps1 -sourcePath $sourcePath -destinationPath $destinationPath -serverName $serverName -serverPort $serverPort -userName $userName -password $password

######################################>

param(
	$sourcePath,
	$destinationPath,
	$serverName,
	$serverPort,
	$userName,
	$password	
)

$pass = ConvertTo-SecureString -AsPlainText $password -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $pass

Write-Host "Creating Remote PowerShell Session, using $userName to connect to $serverName using port $serverPort"
try{
$session = New-PSSession -ComputerName $serverName -Credential $cred -Port $serverPort -SessionOption (New-PSSessionOption -ProxyAccessType NoProxyServer)
}
catch{
Write-Host $_}

Write-Host "Transfering File Using WinRM to $serverName using Port Number $serverPort"
Write-Host "Source File Path: $sourcePath"
Write-Host "Destination Path: $destinationPath"

Write-Host "Checking For Valid Destination Folder"
$testDestinationPath = Invoke-Command -Session $session -ScriptBlock {Test-Path $using:destinationPath}
if($testDestinationPath -eq "True"){
	Write-Host "Destination Path Verified, Moving to File Transfer Process"
}
else{
	Write-Host "Destination FilePath $destinationPath not found on $serverName. Generating Requested Staging Path"
	Invoke-Command -Session $session -ScriptBlock {New-Item -Path $using:destinationPath -ItemType "directory"}
}

Write-Host "Starting File Copy Process"
Copy-Item -Path $sourcePath  -Destination $destinationPath -ToSession $session
Write-Host "File Copy Process Completed"
