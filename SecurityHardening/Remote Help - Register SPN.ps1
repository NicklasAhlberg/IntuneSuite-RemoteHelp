<#	
	.NOTES
	===========================================================================
	 Created on:   	2024-02-19
	 Created by:   	Nicklas Ahlberg
	 Organization: 	rockenroll.tech
	 Filename:     	Remote Help - Register SPN.ps1
	 Version:       1.0.0.1
	===========================================================================
	.DESCRIPTION
		Use this script to register the RemoteAssistanceService SPN in your tenant
	.WARRANTY
		The script is provided "AS IS" with no warranties
    .API-PERMISSIONS
        'Application.ReadWrite.All'
#>

$connectionDetails = @{
    'TenantID' = ''
    'ClientID' = ''
}
$token = (Get-MsalToken @connectionDetails).AccessToken

$body = @"
{
    "appId": "1dee7b72-b80d-4e56-933d-8b6b04f9a3e2"
}
"@

$parameters = @{
    "Uri"         = "https://graph.microsoft.com/v1.0/servicePrincipals"
    "Method"      = "POST"
    "ContentType" = 'application/json'
    "Body"        = $body
}

Invoke-RestMethod -Headers @{ Authorization = "Bearer $($token)" } @parameters