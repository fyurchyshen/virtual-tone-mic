<#
.SYNOPSIS
    Installs the driver as a root-enumerated device in the test VM. Run as Administrator.
.EXAMPLE
    .\install-driver.ps1 -InfPath C:\vtm\VirtualToneMic.inf -HardwareId "Root\VirtualToneMic" -DevconPath C:\vtm\devcon.exe
#>
param(
    [Parameter(Mandatory)][string]$InfPath,
    [Parameter(Mandatory)][string]$HardwareId,
    [string]$DevconPath = 'devcon.exe'
)
$ErrorActionPreference = 'Stop'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated (Administrator) PowerShell.'
}
if (-not (Test-Path $InfPath)) { throw "INF not found: $InfPath" }

Write-Host "Installing $InfPath as $HardwareId ..."
& $DevconPath install $InfPath $HardwareId
if ($LASTEXITCODE -ne 0) { throw "devcon install failed (exit $LASTEXITCODE)" }

Write-Host ''
Write-Host 'Installed. Check Settings > System > Sound > Input for "Virtual Tone Microphone".' -ForegroundColor Green
