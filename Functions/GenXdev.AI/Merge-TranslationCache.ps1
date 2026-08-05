###############################################################################
<#
.SYNOPSIS
Manages the persistent translation cache with batched disk writes per
language.

.DESCRIPTION
Maintains a module-scoped in-memory translation cache for Get-TextTranslation.
The cache is split into per-language JSON files under
$env:LOCALAPPDATA\GenXdev.PowerShell\. Calls to add entries are batched —
disk writes only occur every 100 mutations per language, or when -PersistNow
is called. -PersistNow also clears the in-memory cache to prevent unbounded
growth across processing batches.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER GetCache
Returns the in-memory cache hashtable (language → @{ text → translation }),
loading from per-language disk files on first access.

.PARAMETER Language
BCP 47 language code for the cache entry (e.g., 'nl-NL', 'de-DE').

.PARAMETER Key
The source text being translated.

.PARAMETER Value
The translated text to cache.

.PARAMETER PersistNow
Immediately writes all dirty language caches to disk and clears the
in-memory cache.

.PARAMETER ClearCache
Clears the in-memory cache and deletes all translation-cache-*.json files
from disk.

.PARAMETER PurgeFromCache
Loads all per-language cache files from disk and removes any entries where
the translation is empty, whitespace-only, or identical to the source text
after stripping all non-letter characters (a-z/A-Z). This cleans up failed
translations where the LLM returned the input unchanged (possibly with
appended whitespace or formatting). Writes cleaned caches back to disk.
Reports how many entries were removed per language.

.EXAMPLE
$cache = Merge-TranslationCache -GetCache

.EXAMPLE
Merge-TranslationCache -Language 'nl-NL' -Key 'Hello' -Value 'Hallo'

.EXAMPLE
Merge-TranslationCache -PersistNow

.EXAMPLE
Merge-TranslationCache -PurgeFromCache

#>
function Merge-TranslationCache {

    [CmdletBinding(DefaultParameterSetName = 'Get')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [OutputType([System.Collections.Hashtable])]
    param (
        #######################################################################
        [Parameter(
            ParameterSetName = 'Get',
            Mandatory = $false,
            HelpMessage = 'Return the in-memory cache hashtable'
        )]
        [switch] $GetCache,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Set',
            Mandatory = $true,
            HelpMessage = 'BCP 47 language code for the cache entry'
        )]
        [string] $Language,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Set',
            Mandatory = $true,
            HelpMessage = 'The source text to cache'
        )]
        [string] $Key,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Set',
            Mandatory = $true,
            HelpMessage = 'The translated text to store'
        )]
        [string] $Value,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Persist',
            Mandatory = $true,
            HelpMessage = 'Write all dirty caches to disk and clear memory'
        )]
        [switch] $PersistNow,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Clear',
            Mandatory = $true,
            HelpMessage = 'Clear the in-memory cache and delete all disk files'
        )]
        [switch] $ClearCache,
        #######################################################################
        [Parameter(
            ParameterSetName = 'Purge',
            Mandatory = $true,
            HelpMessage = ('Remove untranslated entries from all language ' +
                'caches on disk')
        )]
        [switch] $PurgeFromCache
        #######################################################################
    )

    begin {
        $cacheDir = [System.IO.Path]::Combine(
            [System.Environment]::GetEnvironmentVariable('LOCALAPPDATA'),
            'GenXdev.PowerShell')
    }

    process {
        #######################################################################
        # --ClearCache: wipe memory and all disk files
        #######################################################################
        if ($ClearCache) {
            $script:__TranslationCache = @{}
            $script:__TranslationCacheLoaded = $false
            $script:__TranslationCacheMutations = @{}

            $pattern = [System.IO.Path]::Combine($cacheDir,
                'translation-cache-*.json')
            $oldFile = [System.IO.Path]::Combine($cacheDir,
                'translation-cache.json')

            $filesToDelete = @(
                [System.IO.Directory]::GetFiles($cacheDir,
                    'translation-cache-*.json'))
            if ([System.IO.File]::Exists($oldFile)) {
                $filesToDelete += $oldFile
            }
            foreach ($f in $filesToDelete) {
                $null = [System.IO.File]::Delete($f)
            }
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Translation cache cleared (memory + disk).')
            return
        }

        #######################################################################
        # --PersistNow: save all dirty languages, clear memory
        #######################################################################
        if ($PersistNow) {
            if ($script:__TranslationCache -and
                $script:__TranslationCache.Count -gt 0) {

                $saved = 0
                foreach ($lang in $script:__TranslationCache.Keys) {
                    $langData = $script:__TranslationCache[$lang]
                    if (-not $langData -or $langData.Count -eq 0) { continue }

                    $langPath = [System.IO.Path]::Combine($cacheDir,
                        "translation-cache-${lang}.json")

                    # Merge with existing on-disk cache for this language
                    if ([System.IO.File]::Exists($langPath)) {
                        $existing = GenXdev\ReadJsonWithRetry `
                            -FilePath $langPath `
                            -AsHashtable `
                            -MaxRetries 5 `
                            -RetryDelayMs 100
                        if ($existing) {
                            foreach ($k in $existing.Keys) {
                                if (-not $langData.ContainsKey($k)) {
                                    $langData[$k] = $existing[$k]
                                }
                            }
                        }
                    }

                    GenXdev\Write-JsonFileAtomic `
                        -FilePath $langPath `
                        -Data $langData `
                        -MaxRetries 5 `
                        -RetryDelayMs 100
                    $saved += $langData.Count
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Persisted ${saved} total entries across " +
                    "$($script:__TranslationCache.Keys.Count) languages.")
            }

            # Clear in-memory cache to prevent unbounded growth
            $script:__TranslationCache = @{}
            $script:__TranslationCacheLoaded = $false
            $script:__TranslationCacheMutations = @{}
            return
        }

        #######################################################################
        # --GetCache: return in-memory cache, loading from disk on first call
        #######################################################################
        if ($GetCache) {
            if (-not $script:__TranslationCacheLoaded) {
                $script:__TranslationCache = @{}
                $script:__TranslationCacheMutations = @{}

                # Load per-language files
                $langFiles = [System.IO.Directory]::GetFiles($cacheDir,
                    'translation-cache-*.json')
                foreach ($f in $langFiles) {
                    try {
                        # Extract language code from filename:
                        # translation-cache-nl-NL.json → nl-NL
                        $fileName = [System.IO.Path]::GetFileNameWithoutExtension(
                            $f)
                        $langCode = $fileName -replace '^translation-cache-',
                            ''
                        $langData = GenXdev\ReadJsonWithRetry `
                            -FilePath $f `
                            -AsHashtable `
                            -MaxRetries 5 `
                            -RetryDelayMs 100
                        if ($langData) {
                            $script:__TranslationCache[$langCode] = $langData
                            $script:__TranslationCacheMutations[$langCode] = 0
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Failed to load cache file '${f}': $_")
                    }
                }

                # Backward compat: also try old monolithic file
                $oldPath = [System.IO.Path]::Combine($cacheDir,
                    'translation-cache.json')
                if (-not $langFiles -and
                    [System.IO.File]::Exists($oldPath)) {
                    try {
                        $oldData = GenXdev\ReadJsonWithRetry `
                            -FilePath $oldPath `
                            -AsHashtable `
                            -MaxRetries 5 `
                            -RetryDelayMs 100
                        if ($oldData) {
                            foreach ($lang in $oldData.Keys) {
                                $script:__TranslationCache[$lang] = $oldData[
                                    $lang]
                                $script:__TranslationCacheMutations[$lang] = 0
                            }
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Failed to load legacy cache: $_")
                    }
                }

                $script:__TranslationCacheLoaded = $true
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Translation cache loaded from disk (' +
                    "$($script:__TranslationCache.Keys.Count) languages).")
            }

            return $script:__TranslationCache
        }

        #######################################################################
        # --PurgeFromCache: remove untranslated entries from all disk caches
        #######################################################################
        if ($PurgeFromCache) {
            $langFiles = @([System.IO.Directory]::GetFiles($cacheDir,
                'translation-cache-*.json'))
            # Also check old monolithic file
            $oldFile = [System.IO.Path]::Combine($cacheDir,
                'translation-cache.json')
            if ([System.IO.File]::Exists($oldFile)) {
                $langFiles += $oldFile
            }

            if ($langFiles.Count -eq 0) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'No translation cache files found to purge.')
                return
            }

            $totalRemoved = 0
            foreach ($f in $langFiles) {
                try {
                    $langData = GenXdev\ReadJsonWithRetry `
                        -FilePath $f `
                        -AsHashtable `
                        -MaxRetries 5 `
                        -RetryDelayMs 100
                    if (-not $langData) { continue }

                    $removed = 0
                    $keysToRemove = [System.Collections.Generic.List[string]]::new()
                    foreach ($entry in $langData.GetEnumerator()) {
                        $k = $entry.Key
                        $v = $entry.Value

                        # Remove empty or whitespace-only values
                        if ([string]::IsNullOrWhiteSpace($v)) {
                            $keysToRemove.Add($k)
                            $removed++
                            continue
                        }

                        # Strip non-letters, compare case-insensitive.
                        # If identical, the translation is bogus.
                        $normalizedKey = $k -replace '[^a-zA-Z]', ''
                        $normalizedVal = $v -replace '[^a-zA-Z]', ''
                        if ($normalizedKey -eq $normalizedVal) {
                            $keysToRemove.Add($k)
                            $removed++
                        }
                    }

                    if ($removed -gt 0) {
                        foreach ($k in $keysToRemove) {
                            $langData.Remove($k)
                        }
                        GenXdev\Write-JsonFileAtomic `
                            -FilePath $f `
                            -Data $langData `
                            -MaxRetries 5 `
                            -RetryDelayMs 100
                        $totalRemoved += $removed
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Purged ${removed} entries from '${f}'.")
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to purge '${f}': $_")
                }
            }

            # Also clear in-memory cache so it reloads clean
            $script:__TranslationCache = @{}
            $script:__TranslationCacheLoaded = $false
            $script:__TranslationCacheMutations = @{}

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Purge complete: removed ${totalRemoved} entries.")
            return
        }

        #######################################################################
        # --Set: add entry to in-memory cache, persist every 100 mutations
        #######################################################################
        if ($Language -and $Key -and $Value) {
            if (-not $script:__TranslationCacheLoaded) {
                # Auto-load if not yet initialized
                $null = GenXdev\Merge-TranslationCache -GetCache
            }

            if (-not $script:__TranslationCache.ContainsKey($Language)) {
                $script:__TranslationCache[$Language] = @{}
                $script:__TranslationCacheMutations[$Language] = 0
            }

            $script:__TranslationCache[$Language][$Key] = $Value
            $script:__TranslationCacheMutations[$Language]++

            # Persist this language every 100 mutations
            if ($script:__TranslationCacheMutations[$Language] -ge 100) {
                $langPath = [System.IO.Path]::Combine($cacheDir,
                    "translation-cache-${Language}.json")

                # Merge with existing on-disk cache
                $merged = $script:__TranslationCache[$Language]
                if ([System.IO.File]::Exists($langPath)) {
                    $existing = GenXdev\ReadJsonWithRetry `
                        -FilePath $langPath `
                        -AsHashtable `
                        -MaxRetries 5 `
                        -RetryDelayMs 100
                    if ($existing) {
                        foreach ($k in $existing.Keys) {
                            if (-not $merged.ContainsKey($k)) {
                                $merged[$k] = $existing[$k]
                            }
                        }
                    }
                }

                GenXdev\Write-JsonFileAtomic `
                    -FilePath $langPath `
                    -Data $merged `
                    -MaxRetries 5 `
                    -RetryDelayMs 100

                $script:__TranslationCacheMutations[$Language] = 0
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Auto-persisted cache for '${Language}' " +
                    "($($merged.Count) entries).")
            }
        }
    }
}