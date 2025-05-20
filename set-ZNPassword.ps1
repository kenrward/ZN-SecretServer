$APIKey = $args[0]
$Username = $args[1]
$NewPassword = $args[2]
$uriBase = $args[3]

# Define log file path
$logFolder = "C:\Scripts\Logs"
$logFile = "$logFolder\ADPasswordChanger.log"

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    # Ensure log folder exists
    if (-not (Test-Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Level] $Message"
    Add-Content -Path $logFile -Value $entry
}

Write-Log "API Key Length $($APIKey.Length)"
if ($uriBase) {
    Write-Log "URL base provided: $UrlPrefix"
} else {
    Write-Log "No URL Prefix provided, exiting."
    exit
}

# Start of script
Write-Log "Starting password change for $Username"

try {
    # Clean username
    $AccountName = $Username.Split('\')[-1]
    Write-Log "Account name normalized: $AccountName"

    # Convert password
    $SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    Write-Log "Converted password to secure string."

    # Change password
    Write-Log "About to execute Set-ADAccountPassword for $AccountName"
    Set-ADAccountPassword -Identity $AccountName -NewPassword $SecurePassword
    Write-Log "Successfully changed AD password for $AccountName"
}
catch {
    Write-Log "Error changing password: $_" -Level "ERROR"
    throw
}

try {
    #Headers
    $znHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $znHeaders.Add("Authorization", $APIKey)
    $znHeaders.Add("content-type", "application/json")

    #Get AD Info
    $api = "settings/asset-management/active-directory"
    $adInfo = Invoke-RestMethod -Uri "$uriBase/$api" -Method Get -Headers $znHeaders

    # Set Payload
    $body = @{
        primaryDomainConfig       = @{
            userFqdn             = $adInfo.forests.activeDirectoryInfo.userFqdn
            password             = $NewPassword
            domainName           = $adInfo.forests.activeDirectoryInfo.domainName
            domainControllerFqdn = $adInfo.forests.activeDirectoryInfo.domainControllerFqdn
            useLdaps             = $adInfo.forests.activeDirectoryInfo.useLdaps
        }
        usePrimaryUserForAllDomains = $true
        allowNtlmFallback         = $true
    }
    $jsonBody = $body | ConvertTo-Json -Depth 10

    $pwapi = "settings/asset-management/active-directory/$($adInfo.forests.forestId)"

    Invoke-RestMethod -Uri "$uriBase/$pwapi" -Method Put -Headers $znHeaders -Body $jsonBody
    Write-Log "Successfully updated API for $AccountName"

}
catch {
    Write-Log "Error calling API update script: $_" -Level "ERROR"
    throw
}

Write-Log "Password change process completed for $AccountName"