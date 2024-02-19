<#	
	.NOTES
	===========================================================================
	 Created on:   	2024-02-19
	 Created by:   	Nicklas Ahlberg
	 Organization: 	rockenroll.tech
	 Filename:     	Remote Help - Create Entra ID Device Groups.ps1
	 Version:       1.0.0.1
	===========================================================================
	.DESCRIPTION
		Use this script to create site specific Windows Autopilot group tag groups
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
        "displayName": "$siteName - Windows Autopilot devices",
        "mailEnabled": false,
        "mailNickname": "AutopilotDevices$mailNickname",
        "securityEnabled": true,
        "description": "All $siteName Windows Autopilot devices",
        "groupTypes": [
            "DynamicMembership"
        ],
        "membershipRule": "(device.devicePhysicalIds -any _ -eq \"[OrderID]:$siteName\")",
        "membershipRuleProcessingState": "On"
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