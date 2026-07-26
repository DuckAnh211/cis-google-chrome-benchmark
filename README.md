<div align="center">
  <h1>CIS Google Chrome Benchmark Security Assessment</h1>
  <p>
    Browser hardening project with a final report, benchmark control mapping,
    PowerShell audit scripts, and a Windows policy baseline.
  </p>
</div>

## Overview

This repository presents a practical security assessment project based on the CIS Google Chrome Benchmark. It turns the report topic into a small, runnable toolkit for checking Chrome enterprise policies on Windows and documenting browser hardening evidence.

The project is designed for portfolio review: a recruiter or reviewer can see the final report, the assessment methodology, the policy baseline, and the scripts used to support the benchmark review.

## Project Snapshot

| Item | Details |
| --- | --- |
| Project type | Security benchmark assessment and hardening toolkit |
| Standard | CIS Google Chrome Benchmark |
| Target | Google Chrome policy configuration on Windows |
| Main deliverable | [Final PDF report](docs/Nhom05_FinalReport.pdf) |
| Code deliverables | PowerShell audit script, hardening script, JSON baseline, registry template |
| Focus areas | Safe browsing, downloads, credentials, extensions, privacy, site permissions, profile control, network behavior |

## Key Deliverables

| Deliverable | Path | Purpose |
| --- | --- | --- |
| Final report | `docs/Nhom05_FinalReport.pdf` | Full project report |
| Baseline controls | `config/cis-chrome-baseline.json` | Machine-readable Chrome policy baseline |
| Audit script | `scripts/Test-ChromeCisBaseline.ps1` | Checks local Chrome policy state against the baseline |
| Hardening script | `scripts/Set-ChromeCisBaseline.ps1` | Applies selected baseline settings through Windows Registry policy keys |
| Registry template | `templates/chrome-cis-baseline.reg` | Manual review/import version of the baseline |
| Control mapping | `docs/control-mapping.md` | Explains each control, policy key, expected value, and security rationale |
| Runbook | `docs/runbook.md` | Step-by-step usage instructions |
| Sample evidence | `evidence/sample-audit-result.json` | Example audit output for documentation |

## Assessment Workflow

```text
CIS Benchmark
    -> control mapping
    -> JSON policy baseline
    -> PowerShell audit
    -> evidence output
    -> final report
```

## Quick Start

Audit the current machine's Chrome policy posture:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Test-ChromeCisBaseline.ps1
```

Save audit evidence locally:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Test-ChromeCisBaseline.ps1 -OutputPath .\evidence\audit-result.local.json
```

Preview hardening changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-ChromeCisBaseline.ps1 -WhatIf
```

Apply non-high-impact baseline controls from an elevated PowerShell session:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Set-ChromeCisBaseline.ps1
```

Read the full operational guide in [docs/runbook.md](docs/runbook.md).

## Security Areas Covered

- Safe Browsing protection
- Dangerous download restrictions
- Password manager and autofill controls
- Extension installation governance
- Default site permissions for location, notifications, and popups
- Third-party cookie blocking
- Guest mode restriction
- QUIC protocol control for inspection-focused environments

## Repository Structure

```text
.
+-- config/
|   `-- cis-chrome-baseline.json
+-- docs/
|   +-- Nhom05_FinalReport.pdf
|   +-- control-mapping.md
|   `-- runbook.md
+-- evidence/
|   `-- sample-audit-result.json
+-- scripts/
|   +-- Set-ChromeCisBaseline.ps1
|   `-- Test-ChromeCisBaseline.ps1
+-- templates/
|   `-- chrome-cis-baseline.reg
+-- .gitignore
`-- README.md
```

## Skills Demonstrated

- Security benchmark research
- Browser hardening and endpoint security analysis
- Windows Registry policy configuration
- PowerShell scripting for audit and remediation support
- JSON-based control baseline design
- Evidence collection and technical documentation
- Risk-based recommendation writing

## Portfolio Summary

This project demonstrates the ability to translate a security benchmark into practical controls, write scripts that support assessment evidence, and communicate findings through a structured report.

Suggested CV bullet:

> Built a CIS Google Chrome Benchmark assessment toolkit with PowerShell scripts, JSON policy baselines, registry templates, and a final technical report documenting browser hardening risks and recommendations.

## Disclaimer

This repository is for academic and portfolio purposes. Validate all policies against the official CIS Benchmark and organizational requirements before using them in production.
