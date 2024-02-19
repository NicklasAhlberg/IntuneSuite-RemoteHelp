<#	
	.NOTES
	===========================================================================
	 Created on:   	2024-02-19
	 Created by:   	Nicklas Ahlberg
	 Organization: 	rockenroll.tech
	 Filename:     	Remote Help - Create scope tags.ps1
	 Version:       1.0.0.1
	===========================================================================
	.DESCRIPTION
		Use this script to create site specific scope tags
	.WARRANTY
		The script is provided "AS IS" with no warranties
    .API-PERMISSIONS
        'DeviceManagementRBAC.ReadWrite.All'
#>

$connectionDetails = @{
    'TenantID' = ''
    'ClientID' = ''
}
$token = (Get-MsalToken @connectionDetails).AccessToken


$siteNames = "Site 1", "Site 2", "Site 3" # You site names go here.

$bodies = @()
foreach ($siteName in $siteNames) {
    $bodies += @"
{
	"displayName": "$siteName - Scope tag",
	"description": "This scope tag is targeted against all $siteName Intune objects"
}
"@
}

foreach ($body in $bodies) {
    $parameters = @{
        "Uri"         = "https://graph.microsoft.com/beta/deviceManagement/roleScopeTags"
        "Method"      = "POST"
        "ContentType" = 'application/json'
        "Body"        = $body
    }

    Invoke-RestMethod -Headers @{ Authorization = "Bearer $($token)" } @parameters
}
#Clear-MsalTokenCache