#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
param(
    [string]$BaselinePath,
    [switch]$IncludeHighImpact
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-InputPath {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path (Get-Location) $Path)
}

function Get-ScriptDirectory {
    if ($PSScriptRoot) {
        return $PSScriptRoot
    }

    if ($PSCommandPath) {
        return (Split-Path -Parent $PSCommandPath)
    }

    return (Get-Location).Path
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Set-PolicyValue {
    param(
        [string]$RegistryPath,
        [string]$ValueName,
        [string]$Type,
        $Expected
    )

    if ($Type -eq "list") {
        $listPath = Join-Path $RegistryPath $ValueName

        if ($PSCmdlet.ShouldProcess($listPath, "set Chrome policy list")) {
            New-Item -Path $listPath -Force | Out-Null

            $existingValues = (Get-ItemProperty -Path $listPath).PSObject.Properties |
                Where-Object { $_.Name -match "^\d+$" }

            foreach ($value in $existingValues) {
                Remove-ItemProperty -Path $listPath -Name $value.Name -ErrorAction SilentlyContinue
            }

            $index = 1
            foreach ($item in @($Expected)) {
                New-ItemProperty -Path $listPath -Name ([string]$index) -Value ([string]$item) -PropertyType String -Force | Out-Null
                $index++
            }
        }

        return
    }

    if ($PSCmdlet.ShouldProcess($RegistryPath, "set $ValueName")) {
        New-Item -Path $RegistryPath -Force | Out-Null

        if ($Type -eq "dword") {
            New-ItemProperty -Path $RegistryPath -Name $ValueName -Value ([int]$Expected) -PropertyType DWord -Force | Out-Null
            return
        }

        New-ItemProperty -Path $RegistryPath -Name $ValueName -Value ([string]$Expected) -PropertyType String -Force | Out-Null
    }
}

if ([string]::IsNullOrWhiteSpace($BaselinePath)) {
    $BaselinePath = Join-Path (Get-ScriptDirectory) "..\config\cis-chrome-baseline.json"
}

$resolvedBaselinePath = Resolve-InputPath $BaselinePath
if (-not (Test-Path $resolvedBaselinePath)) {
    throw "Baseline file not found: $resolvedBaselinePath"
}

if (-not (Test-IsAdministrator)) {
    Write-Warning "Machine-level Chrome policies require an elevated PowerShell session."
}

$baseline = Get-Content -LiteralPath $resolvedBaselinePath -Raw | ConvertFrom-Json
$applied = 0
$skipped = 0

foreach ($control in $baseline.controls) {
    if ($control.enforcement -ne "automated") {
        $skipped++
        Write-Host "SKIP $($control.id): manual control"
        continue
    }

    if ($control.highImpact -and -not $IncludeHighImpact) {
        $skipped++
        Write-Host "SKIP $($control.id): high-impact setting, use -IncludeHighImpact after review"
        continue
    }

    Set-PolicyValue `
        -RegistryPath $control.registryPath `
        -ValueName $control.valueName `
        -Type $control.type `
        -Expected $control.expected

    $applied++
    Write-Host "APPLY $($control.id): $($control.title)"
}

Write-Host ""
Write-Host ("Applied: {0} | Skipped: {1}" -f $applied, $skipped)
Write-Host "Restart Chrome or refresh chrome://policy after applying machine policies."
