<######################################

This script is used to get the current value of a field for a work item within Azure DevOps. This script can be called as a standalone script or added to a CI/CD pipeline.
Can be useful when trying to read a specific field within a work item associated with a pipeline run. This is useful when used in conjunction with pre-approval gates in ADO.
For example, we can have a pipeline run the script and retrieve the value from a work item field and determine if the pipeline needs to continue if the field is either true
or false.

Example:

getWorkItemField.ps1 -devOpsUserName $devOpsUserName -devOpsPAT $devOpsPAT -workItemID $workItemID -teamProjectName $teamProjectName 

######################################>

param(
		$devOpsUserName,
    $devOpsPAT,
    $teamProjectName,
    $workItemID
 )

function New-Credentials
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$User,
        [Parameter(Mandatory=$true)]
        [string]$Pass
    )
    $base64authinfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $User, $Pass)))
    Write-Output $base64authinfo
}

function Get-WorkItemFieldValue
{
 param(
        [Parameter(Mandatory=$true)]
        [string]$workItemID,
        [string]$teamProjectName
    )	
    
    # TODO: Update URI call, with the latest version of the API, you can use "https://dev.azure.com/{organization}/{project}/_apis/wit/workitems/{id}?api-version=7.0" instead
    # reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/get-work-item?view=azure-devops-rest-7.0&tabs=HTTP
    $uri='https://dev.azure.com/'+ $teamProjectName +'/_apis/wit/workitems/'+ $workItemID +'?api-version=5.1'       
    $uri = [uri]::EscapeUriString($uri)
	try { 
			$workItem = Invoke-RestMethod -Method Get -Uri $URI -Headers $Header -ContentType application/json
      
      # TODO: With latest versions of ADO, field reference names may change and will need to updated. Run the API "https://dev.azure.com/{organization}/{project}/_apis/wit/fields?api-version=7.0" 
      # to get a list of all field reference names
      # reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/fields/list?view=azure-devops-rest-7.0&tabs=HTTP
      $workItemFieldNameBool = $workItem.fields.'Custom.fieldNameBoolExample'
      if($workItemFieldNameBool -eq 'True'){
          Write-Host "Work Item's custom bool field is true"
          # Outputting "workItemFieldValueBool" variable to pipeline as either True or False to help with further processing. Can be read by following CI/CD tasks
          Write-Host "##vso[task.setvariable variable=workItemFieldValueBool;isOutput=true]'True'"
      }
      else{ 
          Write-Host "Work Item's custom bool field is false"
          Write-Host "##vso[task.setvariable variable=workItemFieldValueBool;isOutput=true]'False'"       
      }
		}
		catch {
            Write-Verbose "Failed to get approval info $_"
            Exit -1
		} 
}

# Create ADO credentials using DevOpsUserName and PAT. 
$auth = New-Credentials -User $devOpsUserName -Pass $devOpsPAT

# Create header using basic auth, used in Invoke-RestMethod
$Header = @{Authorization="Basic $auth"}

Write-Host "WorkItem ID: $workItemID"
Write-Host "Team Project Name: $teamProjectName"

# Calling function to pull field value from work item using
Get-WorkItemFieldValue -workItemID $workItemID -teamProjectName $teamProjectName
