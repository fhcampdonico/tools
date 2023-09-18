<######################################

Script used to replace the version tags within the *.vbproj and wix product files when building an application within a CI/CD pipeline.
Uses the parameters to create a build number. Major, minor, revision, or hotfix number can be replaced by using system variables during build time.

Example: 
.\updateWixVersion.ps1 -projectFilePath $projectFilePath -wixProductFilePath $wixProductFilePath -majorVersion $majorVersion -minorVersion $minorVersion -buildNumber $buildNumber -revision $revision

######################################>

param
(
    $projectFilePath,
    $wixProductFilePath,
    $majorVersion,
    $minorVersion,
    $buildNumber,
    $revision
)

Write-Host "Application Project File Path: $projectFilePath"
Write-Host "Wix Project File Path: $wixProductFilePath"

Write-Host "Retriving Build Run Number from Build Number"
$buildNumber = $buildNumber.Split('.')[3]

$newVersionID = $majorVersion + '.' + $minorVersion + '.' + $buildNumber + '.' + $revision
$projectFileVersion = '<ApplicationVersion>' + $newVersionID + '</ApplicationVersion>'
$wixProjectFileVersion = '<?define ProductVersion = "' + $newVersionID + '"?>'

Write-Host "Updating Version Number in Project File with new version version: $newVersionID"
$lineToReplaceProjectFile = Get-Content $projectFilePath | Select-String "ApplicationVersion"
(Get-Content $projectFilePath).replace($lineToReplaceProjectFile, $projectFileVersion) | Set-Content $projectFilePath
Write-Host "Version Update for $projectFilePath Successful"

Write-Host "Updating Version Number in Wix Product File with new version version: $newVersionID"
$lineToReplaceWixProjectFile = Get-Content $wixProductFilePath | Select-String "define ProductVersion"
(Get-Content $wixProductFilePath).replace($lineToReplaceWixProjectFile, $wixProjectFileVersion) | Set-Content $wixProductFilePath
Write-Host "Version Update for $wixProductFilePath Successful"
