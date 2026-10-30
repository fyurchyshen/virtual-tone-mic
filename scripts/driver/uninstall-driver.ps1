<#
.SYNOPSIS
    Removes the device and deletes the driver package from the driver store. Run as Administrator.
    Reports whether Windows asked for a reboot (spec R1: it shouldn't when no app uses the device).
.EXAMPLE
    .\uninstall-driver.ps1 -HardwareId "Root\VirtualToneMic" -InfName VirtualToneMic.inf -DevconPath C:\vtm\devcon.exe
#>
param(
    [Parameter(Mandatory)][string]$HardwareId,
    [Parameter(Mandatory)][string]$InfName,
    [string]$DevconPath = 'devcon.exe'
)
$ErrorActionPreference = 'Stop'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated (Administrator) PowerShell.'
}

$rebootNeeded = $false

Write-Host "Removing device $HardwareId ..."
$out = & $DevconPath remove $HardwareId 2>&1
$out | ForEach-Object { Write-Host "  $_" }
if (($out -join ' ') -match 'reboot') { $rebootNeeded = $true }

# Find the published name (oemNN.inf) by the original INF name. Locale-independent.
$packages = @(Get-WindowsDriver -Online | Where-Object {
    (Split-Path $_.OriginalFileName -Leaf) -ieq $InfName
})
if ($packages.Count -eq 0) {
    Write-Host "No driver package named $InfName in the driver store." -ForegroundColor Yellow
}
foreach ($p in $packages) {
    Write-Host "Deleting driver package $($p.Driver) ($InfName) ..."
    & pnputil /delete-driver $p.Driver /uninstall
    if ($LASTEXITCODE -eq 3010) { $rebootNeeded = $true }
    elseif ($LASTEXITCODE -ne 0) { Write-Host "  pnputil exit code $LASTEXITCODE" -ForegroundColor Yellow }
}

Write-Host ''
if ($rebootNeeded) {
    Write-Host 'Windows requested a REBOOT. Is an app still using the device? (spec R1)' -ForegroundColor Red
} else {
    Write-Host 'Uninstalled without a reboot request.' -ForegroundColor Green
}
