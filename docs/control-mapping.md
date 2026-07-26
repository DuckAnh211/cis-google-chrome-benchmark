# Control Mapping

This mapping turns the report topic into practical controls that can be checked or enforced on Windows through Chrome enterprise policy registry keys.

| Area | Project control | Registry policy | Expected state | Why it matters |
| --- | --- | --- | --- | --- |
| Safe browsing | `CHROME-SAFE-001` | `SafeBrowsingProtectionLevel` | At least `1` | Helps block phishing, malware, and unsafe downloads |
| Downloads | `CHROME-DOWNLOAD-001` | `DownloadRestrictions` | At least `1` | Reduces risky file download exposure |
| Credentials | `CHROME-PASSWORD-001` | `PasswordManagerEnabled` | `0` | Encourages managed credential storage instead of unmanaged browser storage |
| Credentials | `CHROME-AUTOFILL-001` | `AutofillAddressEnabled` | `0` | Reduces accidental personal data disclosure |
| Credentials | `CHROME-AUTOFILL-002` | `AutofillCreditCardEnabled` | `0` | Reduces payment data exposure |
| Extensions | `CHROME-EXT-001` | `ExtensionInstallBlocklist` | Contains `*` | Blocks unmanaged extensions by default |
| Site permissions | `CHROME-SITE-001` | `DefaultGeolocationSetting` | `2` | Blocks location access by default |
| Site permissions | `CHROME-SITE-002` | `DefaultNotificationsSetting` | `2` | Reduces social engineering through notification prompts |
| Site permissions | `CHROME-SITE-003` | `DefaultPopupsSetting` | `2` | Blocks popup abuse and unwanted redirects |
| Privacy | `CHROME-PRIVACY-001` | `BlockThirdPartyCookies` | `1` | Improves privacy posture |
| Profile control | `CHROME-GUEST-001` | `BrowserGuestModeEnabled` | `0` | Prevents bypass of managed profile expectations |
| Network | `CHROME-QUIC-001` | `QuicAllowed` | `0` | Supports environments that require consistent proxy or inspection controls |

## Notes

- The PowerShell scripts use `config/cis-chrome-baseline.json` as the source of truth.
- The `.reg` template provides the same baseline in a format that can be reviewed or imported manually.
- High-impact settings should be tested before applying them to shared or production machines.
