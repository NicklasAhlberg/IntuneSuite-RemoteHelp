<#	
	.NOTES
	===========================================================================
	 Created on:   	2024-02-19
	 Created by:   	Nicklas Ahlberg
	 Organization: 	rockenroll.tech
	 Filename:     	Remote Help - Create Intune RBAC Role.ps1
	 Version:       1.0.0.1
	===========================================================================
	.DESCRIPTION
		Use this script to create Intune RBAC roles for Remote Help admins
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

# Remove any permission you don't want to keep. Make sure to remove the last "comma" (,)
$allowedResourceActions = @"
"Microsoft.Intune_RemoteAssistanceApp_Elevation",
"Microsoft.Intune_RemoteAssistanceApp_ViewScreen",
"Microsoft.Intune_RemoteAssistanceApp_Unattended",
"Microsoft.Intune_RemoteAssistanceApp_TakeFullControl",
"Microsoft.Intune_RemoteTasks_RequestRemoteAssistance",
"Microsoft.Intune_RemoteTasks_DeviceLogs",
"Microsoft.Intune_RemoteTasks_SyncDevice",
"Microsoft.Intune_ManagedDevices_Read",
"Microsoft.Intune_ManagedDevices_ViewReports"
"@

# Site 1
$siteNames = "Site 1", "Site 2", "Site 3"

$bodies = @()

foreach ($siteName in $siteNames) {
    $bodies += @"
{
    "id": "",
    "description": "This role gives full Remote Help privileges for all $siteName Windows devices",
    "displayName": "Remote Help - $siteName - Full",
    "rolePermissions": [
        {
            "resourceActions": [
                {
                    "allowedResourceActions": [
                        $allowedResourceActions
                    ]
                }
            ]
        }
    ],
    "roleScopeTagIds": [
        "0"
    ]
}
"@
}

# Create each site specific custom Intune RBAC role
foreach ($body in $bodies) {
    $parameters = @{
        "Uri"         = "https://graph.microsoft.com/beta/deviceManagement/roleDefinitions"
        "Method"      = "POST"
        "ContentType" = 'application/json'
        "Body"        = $body
    }

    Invoke-RestMethod -Headers @{ Authorization = "Bearer $($token)" } @parameters
}
#Clear-MsalTokenCache