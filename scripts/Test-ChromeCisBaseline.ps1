#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$BaselinePath,
    [string]$OutputPath,
    [switch]$FailOnNonCompliant
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

function Get-PolicyValue {
    param(
        [string]$RegistryPath,
        [string]$ValueName,
        [string]$Type
    )

    if ($Type -eq "list") {
        $listPath = Join-Path $RegistryPath $ValueName
        if (-not (Test-Path $listPath)) {
            return $null
        }

        $item = Get-ItemProperty -Path $listPath
        $values = $item.PSObject.Properties |
            Where-Object { $_.Name -match "^\d+$" } |
            Sort-Object { [int]$_.Name } |
            ForEach-Object { [string]$_.Value }

        return @($values)
    }

    if (-not (Test-Path $RegistryPath)) {
        return $null
    }

    $item = Get-ItemProperty -Path $RegistryPath
    $property = $item.PSObject.Properties[$ValueName]

    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Test-PolicyValue {
    param(
        $Actual,
        $Expected,
        [string]$Type,
        [string]$Comparison
    )

    if ($null -eq $Actual) {
        return $false
    }

    switch ($Comparison) {
        "atLeast" {
            return ([int]$Actual -ge [int]$Expected)
        }
        "containsAll" {
            $actualList = @($Actual | ForEach-Object { [string]$_ })
            $expectedList = @($Expected | ForEach-Object { [string]$_ })

            foreach ($item in $expectedList) {
                if ($actualList -notcontains $item) {
                    return $false
                }
            }

            return $true
        }
        default {
            if ($Type -eq "dword") {
                return ([int]$Actual -eq [int]$Expected)
            }

            return ([string]$Actual -eq [string]$Expected)
        }
    }
}

if ([string]::IsNullOrWhiteSpace($BaselinePath)) {
    $BaselinePath = Join-Path (Get-ScriptDirectory) "..\config\cis-chrome-baseline.json"
}

$resolvedBaselinePath = Resolve-InputPath $BaselinePath
if (-not (Test-Path $resolvedBaselinePath)) {
    throw "Baseline file not found: $resolvedBaselinePath"
}

$baseline = Get-Content -LiteralPath $resolvedBaselinePath -Raw | ConvertFrom-Json
$results = foreach ($control in $baseline.controls) {
    $actual = Get-PolicyValue `
        -RegistryPath $control.registryPath `
        -ValueName $control.valueName `
        -Type $control.type

    $passed = Test-PolicyValue `
        -Actual $actual `
        -Expected $control.expected `
        -Type $control.type `
        -Comparison $control.comparison

    [pscustomobject]@{
        id = $control.id
        title = $control.title
        category = $control.category
        severity = $control.severity
        registryPath = $control.registryPath
        valueName = $control.valueName
        expected = $control.expected
        actual = $actual
        status = if ($passed) { "PASS" } else { "FAIL" }
        remediation = $control.remediation
    }
}

$summary = [pscustomobject]@{
    total = @($results).Count
    pass = @($results | Where-Object { $_.status -eq "PASS" }).Count
    fail = @($results | Where-Object { $_.status -eq "FAIL" }).Count
}

$report = [pscustomobject]@{
    tool = "CIS Chrome Benchmark Audit"
    generatedAt = (Get-Date).ToString("o")
    computerName = $env:COMPUTERNAME
    baseline = $baseline.metadata.name
    baselineVersion = $baseline.metadata.version
    summary = $summary
    results = @($results)
}

Write-Host "CIS Chrome Benchmark Audit"
Write-Host ("Total: {0} | Pass: {1} | Fail: {2}" -f $summary.total, $summary.pass, $summary.fail)
Write-Host ""

$results |
    Sort-Object status, severity, id |
    Format-Table id, status, severity, category, title -AutoSize

if ($OutputPath) {
    $resolvedOutputPath = Resolve-InputPath $OutputPath
    $outputDirectory = Split-Path -Parent $resolvedOutputPath

    if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    }

    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resolvedOutputPath -Encoding UTF8
    Write-Host ""
    Write-Host "Audit evidence written to $resolvedOutputPath"
}

if ($FailOnNonCompliant -and $summary.fail -gt 0) {
    exit 1
}
