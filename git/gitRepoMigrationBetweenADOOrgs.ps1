<######################################

This is a small base script that allows you to easily migrate a git repo from one Azure DevOps org to another.
In addition, this script handles the case where commits linked to work items in the source ADO org are not replicated
within the target ADO org as Git is not smart enough to realize that the work item in one ADO org is different than 
the work item in another one.

The final version requires user to provide PAT as part of the authentication process

Example:

Commit A is associated with work item 123 (complete task A) in ADO Org 1. If you use the ADO tool to perform 
the migration, then post migration, commit A, would be associated with work item 123 (complete task B) in 
ADO org 2.

Pre-reqs:

1. User must be an admin to team projects in orgs and must be able to provide full PAT access tokens
2. PS Version 5 or greater
3. Git for Windows installed
4. Git credential manager has been enabled
  https://learn.microsoft.com/en-us/azure/devops/repos/git/set-up-credential-managers?view=azure-devops
5. Install Python 3.10 or higher
6. Install git-filter-repo module
  https://github.com/newren/git-filter-repo/blob/main/INSTALL.md
7. Git, Python, and git-filter-repo have been added to environment variable path
8. Repo in target org is an empty repo (no readme or .gitignore) and no branch policies enabled

Steps:

1. Copy script into a empty folder in your local machine
2. Open a PS Window and go to the script
3. Run "git config --global credential.helper.cache"
  If this step isn't run, then you will need to enter your ADO PATs during run time
4. Enter the correct $sourceRepo, $destinationRepo, and "newmsg" value containing the URL.
  Note, if your clone URL's have a space, you you will need to add "%20" to ensure space is accounted for
5. Run the script
#######################################>

$sourceRepo = "https://azuredevopsSource/<teamProjectName>/_git/sourceCloneURL" #source repo clone UR
$destinationRepo = "https://azuredevopsTarget/teamProjectName/_git/targetCloneURL" #target repo clone URL

$repoName = $sourceRepo.Substring($sourceRepo.LastIndexOf("/")+1)
$scriptPath = Get-Location
$gitRepoPath = Join-Path -Path $scriptPath -ChildPath $repoName

Write-Host "Starting Migration Process for $repoName"
Write-Host "Creating temporary $repoName migration fodler"
New-Item $gitRepoPath -ItemType "directory"

Write-Host "Cloning Source Repo"
git clone $sourceRepo

Write-Host "Starting Repository History Cleanup"
Set-Location $gitRepoPath
git filter-repo --commit-callback '
msg = commit.message.decode(\"utf-8\")
newmsg = msg.replace(\"#\", \"https://azuredevopsSource/<teamProjectName>/_workitems/edit/\")
commit.message = newmsg.encode(\"utf-8\")
' --force

Write-Host "Pushing repo with modified history to $destinationRepo"
git push --mirror $destinationRepo

Write-Host "removing temporary migration folder"
Set-Location $scriptPath
Remove-Item $gitRepoPath -force -recurse
