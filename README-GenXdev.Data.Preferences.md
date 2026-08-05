# GenXdev.Data.Preferences

## Overview

GenXdev.Data.Preferences provides a tiered preference system: a
session-scoped global variable for temporary overrides, and persistent
JSON-based key-value stores for durable storage with support for
synchronization over Onedrive.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md) | `setPreference` | Store a preference value persistently |
| [Get-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreference.md) | `getPreference` | Retrieve a preference value |
| [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md) | `setPreferenceDefault` | Set a default value, used when no explicit preference exists |
| [Remove-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-GenXdevPreference.md) | `removePreference` | Delete a preference |
| [Get-GenXdevPreferenceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferenceNames.md) | `getPreferenceNames` | List all known preference names |
| [Get-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferencesDatabasePath.md) | — | Get the filesystem path to the preferences database |
| [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md) | — | Change where the preferences database lives |

## How It All Comes Together

When you run `Set-AILLMSettings` to configure an LLM provider, it stores
the settings as preferences. When `Open-Webbrowser` needs to know which
monitor to use, it reads `DefaultSecondaryMonitor` from preferences. When
`Confirm-InstallationConsent` asks if you want to auto-install tools, the
answer is persisted as a preference.

`Get-GenXdevPreference` looks up values through a five-tier fallback,
reading from disk at each persistent tier (nothing is held in memory
between lookups):

1. **Session variable** — a global PowerShell variable set by a previous
   `Set-GenXdevPreference` in this session, or explicitly via `-SessionOnly`
2. **Local preferences** — `GenXdev.PowerShell.Preferences` JSON store
3. **Local defaults** — `GenXdev.PowerShell.Defaults` JSON store
4. **OneDrive defaults** — `OneDrive\GenXdev\Defaults_Preferences.json`
5. **Hardcoded fallback** — the `-DefaultValue` parameter or the module's
   built-in default

If the exact (lowercased) key isn't found, it does a second pass with
case-insensitive scanning across all tiers before falling back.

`Set-GenXdevPreference` writes to local preferences and the session
variable. `Set-GenXdevDefaultPreference` writes to local defaults and the
session variable, but only if no existing value is found — so modules can
ship with sensible defaults that users can override.

### Cross-Machine Sharing via OneDrive

Preferences can be shared across machines through OneDrive, but it's opt-in
per write — nothing syncs unless you explicitly ask for it.

The lookup on read always checks the five tiers listed above in order. So if a
preference was written to OneDrive from another machine (and OneDrive has
synced the file), it gets picked up automatically during reads.

To write a preference to OneDrive, use `-AllMachines`:

```powershell
Set-GenXdevPreference -Name "Theme" -Value "Dark" -AllMachines
Set-GenXdevDefaultPreference -Name "Theme" -Value "Dark" -AllMachines
```

Both cmdlets write to `OneDrive\GenXdev\Defaults_Preferences.json` when
`-AllMachines` is specified. Without that switch, preferences stay local.
On another machine signed into the same OneDrive account, the synced file
is read as tier 4 of the lookup chain. If OneDrive isn't available, the
write silently falls back to local-only.

Preferences are also used by GenXdev.Coding's refactoring engine (refactor
definitions are stored as JSON preferences), GenXdev.Console's monitor
configuration, and GenXdev.Software's installation consent tracking.

## See Also

- [GenXdev.Data.KeyValueStore](README-GenXdev.Data.KeyValueStore.md) — JSON file storage
- [GenXdev.AI](README-GenXdev.AI.md) — LLM settings stored as preferences
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevdatapreferences)
