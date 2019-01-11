#Requires -Version 4.0

[CmdletBinding()]
Param()

Write-Verbose "Importing all public functions in:  ${PSScriptRoot}"

foreach ( $Folder in @( 'Private', 'Public' ) ) {

    $Root = Join-Path -Path $PSScriptRoot -ChildPath $Folder
    if ( Test-Path -Path $Root ) {
        Write-Verbose "Processing files in:  ${Root}"

        $Files = Get-ChildItem -Path $Root -Filter *.ps1 -Recurse

        # Dot source each file.
        $Files | ForEach-Object { Write-Verbose $_.basename; . $PSItem.FullName }
    }
}

Export-ModuleMember -Function ( Get-ChildItem -Path "${PSScriptRoot}\Public\*.ps1" ).BaseName
# Export-ModuleMember -Function ( Get-ChildItem -Path "${PSScriptRoot}\Private\*.ps1" ).BaseName

##################################################
# Run after loading the module

$URL = $( Read-Host "Please specify the Jamf Pro Server URL (https://jamf.company.com:8443)" )
$Save = $( Read-Host "Would you like to permanently save this to you your user environment for furture use?" )

# Set the JPS Server URL in the PowerShell Environment
Set-JamfServer -Url "${URL}" -Save "${Save}"

# Set the session to use TLS 1.2
Write-Host "Setting session Security Protocol to TLS 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get available API resource endpoints from the JPS
$global:APIResources = Get-JamfAPIResources -Server "${env:JamfProServer}"
