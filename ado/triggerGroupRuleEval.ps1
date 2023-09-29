<######################################

This script is used to trigger Azure DevOps Group Rules Re-Evaluations. Usually, group rule re-evaluation is trigger once every 24 hours by the system.
However, it can also be triggered manually in order to sync users with groups. Unfortunately, this process is at the whim of MS scheduling. However,
this script uses a beta version API to trigger the re-evaluation and can be added to a pipeline as a task. Very useful when we need to ensure group rules and
AAD groups are in sync. 

Example:

.\TriggerADOGroupRuleReEvaluation.ps1 -orgName $orgName -devOpsUserName $devOpsUserName -devOpsPAT $devOpsPAT

######################################>

param(
    $orgName,
    $devOpsUserName,
    $devOpsPAT
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

function TriggerGroupRuleReEvaluation{
    param(
        [Parameter(Mandatory=$true)]
        [string]$orgName
    )
    # TODO: Investigate and Update URI call, with the latest version of the API, could be used with updated 7 API version with user/group entitlements 
    # reference: https://learn.microsoft.com/en-us/rest/api/azure/devops/memberentitlementmanagement/?view=azure-devops-rest-7.1
    #            https://learn.microsoft.com/en-us/rest/api/azure/devops/memberentitlementmanagement/group-entitlements/list?view=azure-devops-rest-7.1&tabs=HTTP
    $uri = "https://vsaex.dev.azure.com/" + $orgName + "/_apis/MEMInternal/GroupEntitlementUserApplication?ruleOption=0&api-version=6.0-preview.1"
    $uri = [uri]::EscapeUriString($uri)
    try{
        Invoke-RestMethod -Method 'Post' -Uri $uri -Headers $Header -ContentType application/json
    }
    catch {
            Write-Verbose "Failed to Trigger Group Rule Re-Evaluation"
            Exit -1
		} 
}

$auth = New-Credentials -User $devOpsUserName -Pass $devOpsPAT
$Header = @{Authorization="Basic $auth"}

Write-Output "Triggering Group Rule Re-Evaluation on $orgName"
TriggerGroupRuleReEvaluation -orgName $orgName
