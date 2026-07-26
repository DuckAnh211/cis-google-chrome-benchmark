# Runbook

This runbook explains how to use the repository as a small Chrome benchmark assessment toolkit.

## 1. Review the Baseline

Open the baseline file and review each control:

```powershell
Get-Content .\config\cis-chrome-baseline.json
```

Check the `highImpact` field before applying settings. High-impact controls can change normal user workflows.

## 2. Audit Local Chrome Policies

Run the audit script from a PowerShell terminal:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Test-ChromeCisBaseline.ps1
```

Write audit evidence to JSON:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Test-ChromeCisBaseline.ps1 -OutputPath .\evidence\audit-result.local.json
```

The generated `audit-result.local.json` file is ignored by Git so local machine details are not committed by accident.

## 3. Apply the Baseline

Open PowerShell as Administrator, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-ChromeCisBaseline.ps1 -WhatIf
```

If the preview is acceptable, apply the non-high-impact controls:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-ChromeCisBaseline.ps1
```

Apply high-impact controls only after review:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-ChromeCisBaseline.ps1 -IncludeHighImpact
```

## 4. Verify in Chrome

After applying machine policies:

1. Restart Chrome.
2. Open `chrome://policy`.
3. Click `Reload policies`.
4. Confirm that the expected policies appear.

## 5. Attach Evidence to the Report

Use the audit output as supporting evidence for the final report:

```text
Benchmark guidance -> Baseline JSON -> Audit script -> Evidence JSON -> Final report
```
