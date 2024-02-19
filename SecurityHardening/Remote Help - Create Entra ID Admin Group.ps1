<#	
	.NOTES
	===========================================================================
	 Created on:   	2024-02-19
	 Created by:   	Nicklas Ahlberg
	 Organization: 	rockenroll.tech
	 Filename:     	Remote Help - Create Entra ID Admin group.ps1
	 Version:       1.0.0.1
	===========================================================================
	.DESCRIPTION
		Use this script to create Entra ID groups for Remote Help admins
	.WARRANTY
		The script is provided "AS IS" with no warranties
    .API-PERMISSIONS
        'Group.ReadWrite.All', 'RoleManagement.ReadWrite.Directory'
#>

$connectionDetails = @{
    'TenantID' = ''
    'ClientID' = ''
}
$token = (Get-MsalToken @connectionDetails).AccessToken

$siteNames = "Site 1", "Site 2", "Site 3" # You site names go here.

$bodies = @()
foreach ($siteName in $siteNames) {
    $mailNickname = $siteName.replace(' ','')
    $bodies += @"
{
    "displayName": "Intune - Remote Help Admins - $siteName",
    "mailEnabled": false,
    "securityEnabled": true,
    "mailNickname": "RemoteHelpAdmins$mailNickname",
    "description": "Members of this group will be given full Remote Help administrative privileges for $siteName devices",
    "isAssignableToRole": true
}
"@
}

foreach ($body in $bodies) {
    $parameters = @{
        "Uri"         = "https://graph.microsoft.com/v1.0/groups"
        "Method"      = "POST"
        "ContentType" = 'application/json'
        "Body"        = $body
    }

    Invoke-RestMethod -Headers @{ Authorization = "Bearer $($token)" } @parameters
}
#Clear-MsalTokenCache