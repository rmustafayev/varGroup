param(
 
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter your Azure DevOps organization name')]
    [String]$organizationName,
 
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter your Azure DevOps project name')]
    [String]$projectName,
 
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter your personal access token to authenticate to Azure Devops')]
    [String]$PAT,
    
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter the User Principal Name (someone@example.com)')]
    [String]$UPN,
     
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter the Variable Group filter')]
    [String]$groupFilter,
     
    [Parameter(Mandatory = $true, HelpMessage = 'Please enter the Security Role for Variable Group')]
    [String]$roleName
)


$adoUri = "https://dev.azure.com/" + $organizationName + "/" + $projectName 

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

# Get variable group IDs
$groupsUri = $adoUri + '/_apis/distributedtask/variablegroups?api-version=5.1-preview.1'
$varGroups = Invoke-RestMethod -Uri $groupsUri -Method Get -Headers @{Authorization = "Basic $base64AuthInfo" }

$varGroupIds = foreach ($group in $varGroups.value) {
    if ($group.name -like "*$groupFilter*") {
        $group.id
    }
}
if ($varGroupIds.Count -eq 0) {
    Write-Error "Variable Group containing $groupFilter not found"
}

# Get User ID
$uriUserEntitlements = "https://vsaex.dev.azure.com/" + $organizationName + "/_apis/userentitlements?api-version=5.1-preview.2"
$userEntitlements = Invoke-RestMethod -Uri $uriUserEntitlements -Method get -Headers @{Authorization = "Basic $base64AuthInfo" }
$userData = $userEntitlements.members | Where-Object { $_.user.principalName -eq $UPN }
$userid = $userData.id
if ($userData.Count -eq 0) {
    Write-Error "UPN $UPN not found"
}

# Get ProjectID
$accountUri = "https://dev.azure.com/" + $organizationName + "/_apis/projects?api-version=6.0"
$projects = Invoke-RestMethod -Uri $accountUri -Method get -Headers @{Authorization = "Basic $base64AuthInfo" }

$project = $projects.value | Where-Object { $_.Name -eq $projectName }
$projectID = $Project.id

# Add user to Security Group
$requestBody = "[{roleName: `"$roleName`", userId: `"$userId`"}]"

foreach ($groupId in $varGroupIds) {
    $encodedValue = [System.Web.HttpUtility]::UrlEncode('$' + $groupId)
    $secUri = "https://dev.azure.com/" + $organizationName + "/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$projectID$encodedValue" + "?api-version=7.2-preview.1"
    Invoke-RestMethod -Uri $secUri -Method put  -Headers @{Authorization = "Basic $base64AuthInfo" } -Body $requestBody -ContentType "application/json"
}  
