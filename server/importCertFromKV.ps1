<######################################

Script to retrieve a cert from KV, adding it to the local store, and using it to sign a build assembly

Example: 

.\importCertFromKV.ps1 -sourcePath $sourcePath -destinationPath $destinationPath -serverName $serverName -serverPort $serverPort -userName $userName -password $password

######################################>

param
(
    $ConnectedServiceName,
    $ResourceGroupName,
    $VaultName,
    $SecretName
)

Write-Host "Importing AzureRM.Profile and AzureRM.KeyVault Modules."
Import-Module AzureRM.Profile
Import-Module AzureRM.KeyVault

Write-Host "Subscription: $ConnectedServiceName"
Write-Host "Key Vault Name: $VaultName"
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Secret Name: $SecretName"

Write-Host "Getting $VaultName Vault Name from $ResourceGroupName Resource Group"
$vault = Get-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName

Write-Host "Getting $SecretName Certificate Name from $VaultName vault"
$AzureKeyVaultSecret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $SecretName

Write-Host "Getting Secret Bytes"
$SecretBytes = [system.convert]::FromBase64String($AzureKeyVaultSecret.SecretValueText)

Write-Host "Importing Certificate Collection from Secret Bytes"
$CertCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$CertCollection.Import($SecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)

Write-Host "Adding Certificate to Local Server"
Write-Host "Creating new Certificate Store Object for CurrentUser-My Store"
$CertificateStore = New-Object System.Security.Cryptography.X509Certificates.X509Store([System.Security.Cryptography.X509Certificates.StoreName]::My,[System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser)

Write-Host "Enabling Store to be written"
$CertificateStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

Write-Host "Adding Certificate to Store"
$CertificateStore.Add($CertCollection)

Write-Host "Closing Store"
$CertificateStore.Close()
