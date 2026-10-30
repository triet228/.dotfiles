$ErrorActionPreference = "Stop"
$BackupExisting = $args -contains "-BackupExisting"
$Repo = $PSScriptRoot
$Documents = [Environment]::GetFolderPath("MyDocuments")
$BackupRoot = Join-Path $HOME (".dotfiles-backup\windows\" + (Get-Date -Format "yyyyMMdd-HHmmss-fffffff"))
$CopyStatePath = Join-Path $HOME ".local\state\dotfiles\windows-copies.json"
$CopyState = @{}
$CopyStateChanged = $false
if (Test-Path -LiteralPath $CopyStatePath) {
    $SavedState = Get-Content -LiteralPath $CopyStatePath -Raw | ConvertFrom-Json
    foreach ($Property in $SavedState.PSObject.Properties) {
        $CopyState[$Property.Name] = $Property.Value
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "This installer requires Windows."
}

function Backup-Config {
    param($Target, $CopyOnly = $false)

    # Preserve the home-relative layout so each backup has an unambiguous restore path.
    $FullTarget = [IO.Path]::GetFullPath($Target)
    $HomePrefix = $HOME.TrimEnd('\') + '\'
    if (-not $FullTarget.StartsWith($HomePrefix, [StringComparison]::OrdinalIgnoreCase) -or
        $Repo.StartsWith($FullTarget.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase) -or
        $FullTarget -eq $Repo) {
        throw "Refusing to move a path outside the managed home configuration: $Target"
    }

    $Backup = Join-Path $BackupRoot $FullTarget.Substring($HomePrefix.Length)
    New-Item -ItemType Directory -Path (Split-Path -Parent $Backup) -Force | Out-Null
    if ($CopyOnly) {
        Copy-Item -LiteralPath $FullTarget -Destination $Backup -ErrorAction Stop
    } else {
        Move-Item -LiteralPath $FullTarget -Destination $Backup -ErrorAction Stop
    }
    Write-Host "Backed up: $Target -> $Backup"
}

$Links = @(
    @{ Source = ".config\alacritty"; Target = "$env:APPDATA\alacritty" },
    @{ Source = ".config\fastfetch"; Target = "$HOME\.config\fastfetch" },
    @{ Source = ".config\git"; Target = "$HOME\.config\git" },
    @{ Source = ".config\lf"; Target = "$HOME\.config\lf" },
    @{ Source = ".config\nvim"; Target = "$HOME\.config\nvim" },
    @{ Source = ".config\nvim"; Target = "$env:LOCALAPPDATA\nvim" },
    @{ Source = ".config\lf\lfrc.windows"; Target = "$env:LOCALAPPDATA\lf\lfrc" },
    @{ Source = ".config\lf\icons"; Target = "$env:LOCALAPPDATA\lf\icons" },
    @{ Source = ".config\lf\previewer.cmd"; Target = "$env:LOCALAPPDATA\lf\previewer.cmd" },
    @{ Source = ".config\lf\previewer.ps1"; Target = "$env:LOCALAPPDATA\lf\previewer.ps1" },
    @{ Source = ".config\powershell"; Target = "$HOME\.config\powershell" },
    @{ Source = ".codex\AGENTS.md"; Target = "$HOME\.codex\AGENTS.md" },
    @{ Source = ".codex\AGENTS.md"; Target = "$HOME\.claude\CLAUDE.md" },
    @{ Source = ".claude\settings.json"; Target = "$HOME\.claude\settings.json" },
    @{ Source = ".vimrc"; Target = "$HOME\.vimrc" },
    # OpenSSH rejects files with the repository's broader inherited permissions.
    @{ Source = ".ssh\config"; Target = "$HOME\.ssh\config"; CopyOnly = $true },
    @{ Source = ".local\bin\trash-put.cmd"; Target = "$HOME\.local\bin\trash-put.cmd" },
    @{ Source = ".local\bin\trash-put.ps1"; Target = "$HOME\.local\bin\trash-put.ps1" },
    @{ Source = ".local\bin\clean.cmd"; Target = "$HOME\.local\bin\clean.cmd" },
    @{ Source = ".local\bin\clean.ps1"; Target = "$HOME\.local\bin\clean.ps1" },
    @{ Source = ".local\bin\trash.cmd"; Target = "$HOME\.local\bin\trash.cmd" },
    @{ Source = ".config\powershell\Microsoft.PowerShell_profile.ps1"; Target = "$Documents\PowerShell\Microsoft.PowerShell_profile.ps1" },
    @{ Source = ".config\powershell\Microsoft.PowerShell_profile.ps1"; Target = "$Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
)

$Created = @()
$AlreadyLinked = @()
$Conflicts = @()

function Get-LinkTarget {
    param($Item)

    if ($Item.Target) {
        return ($Item.Target -join ", ")
    }

    return ""
}

function Test-SameFile {
    param($Left, $Right)

    if (-not (Test-Path -LiteralPath $Left) -or -not (Test-Path -LiteralPath $Right)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $Left -PathType Leaf) -or -not (Test-Path -LiteralPath $Right -PathType Leaf)) {
        return $false
    }

    return (Get-FileHash -LiteralPath $Left).Hash -eq (Get-FileHash -LiteralPath $Right).Hash
}

function Test-RoutesToSource {
    param($Target, $Source)

    if (-not (Test-Path -LiteralPath $Target)) {
        return $false
    }

    $TargetItem = Get-Item -LiteralPath $Target -Force
    $NestedTarget = Get-LinkTarget $TargetItem
    return $TargetItem.LinkType -and $NestedTarget -eq $Source
}

function Get-LoaderContent {
    param($Source, $Target)

    # Load executable configuration from the checkout so Git replacements take effect immediately.
    if ([IO.Path]::GetExtension($Source) -eq ".ps1") {
        $QuotedSource = $Source.Replace("'", "''")
        $Operator = if ($Source.EndsWith("Microsoft.PowerShell_profile.ps1")) { "." } else { "&" }
        return "# Managed by setup-windows-symlinks.ps1.`n$Operator '$QuotedSource' @args`n"
    }
    if ((Split-Path -Leaf $Target) -eq ".vimrc") {
        $QuotedSource = $Source.Replace('\', '/').Replace("'", "''")
        return "execute 'source ' . fnameescape('$QuotedSource')`n"
    }
    if ((Split-Path -Leaf $Target) -eq "lfrc") {
        $QuotedSource = $Source.Replace('\', '/').Replace('"', '\"')
        return "source `"$QuotedSource`"`n"
    }
}

function Get-DesiredHash {
    param($Source, $LoaderContent)

    if ($LoaderContent) {
        $Hasher = [Security.Cryptography.SHA256]::Create()
        try {
            return [BitConverter]::ToString($Hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($LoaderContent))).Replace('-', '')
        } finally {
            $Hasher.Dispose()
        }
    }
    return (Get-FileHash -LiteralPath $Source).Hash
}

$UseFileSymlinks = $true
$Probe = Join-Path $env:TEMP "dotfiles-symlink-probe-$([guid]::NewGuid().ToString('N'))"
try {
    New-Item -ItemType SymbolicLink -Path $Probe -Target (Join-Path $Repo 'README.md') -ErrorAction Stop | Out-Null
} catch {
    $UseFileSymlinks = $false
    Write-Host "File symlinks unavailable; using directory junctions, loaders, and managed copies."
} finally {
    if (Get-Item -LiteralPath $Probe -Force -ErrorAction SilentlyContinue) {
        Remove-Item -LiteralPath $Probe -Force
    }
}

foreach ($Link in $Links) {
    $Source = Join-Path $Repo $Link.Source
    $Target = $Link.Target
    $UseFileLink = $UseFileSymlinks -and -not $Link.CopyOnly

    if (-not (Test-Path -LiteralPath $Source)) {
        $Conflicts += "missing source: $Source"
        continue
    }

    $Parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }

    $Item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    $LoaderContent = $null
    $DesiredHash = $null
    if (-not $UseFileLink -and (Test-Path -LiteralPath $Source -PathType Leaf)) {
        $LoaderContent = Get-LoaderContent $Source $Target
        $DesiredHash = Get-DesiredHash $Source $LoaderContent
        if ($Item -and -not $Item.LinkType -and -not $Item.PSIsContainer -and
            (Get-FileHash -LiteralPath $Target).Hash -eq $DesiredHash) {
            if ($CopyState[$Target] -ne $DesiredHash) { $CopyStateChanged = $true }
            $CopyState[$Target] = $DesiredHash
            $AlreadyLinked += "$Target (managed loader/copy)"
            continue
        }
    }
    if ($Item -and -not $Item.LinkType -and -not $Item.PSIsContainer -and $CopyState.ContainsKey($Target) -and
        (Get-FileHash -LiteralPath $Target).Hash -eq $CopyState[$Target]) {
        # Only refresh a managed copy when its last installed content is still intact.
        Remove-Item -LiteralPath $Target -Force
        $Item = $null
    }
    if ($Item) {
        $ExistingTarget = Get-LinkTarget $Item

        if (-not $Link.CopyOnly -and $Item.LinkType -and $Item.LinkType -ne "HardLink" -and $ExistingTarget -eq $Source) {
            $AlreadyLinked += $Target
            continue
        }

        if (-not $Link.CopyOnly -and $Item.LinkType -and $Item.LinkType -ne "HardLink" -and (Test-RoutesToSource $ExistingTarget $Source)) {
            $AlreadyLinked += "$Target -> $ExistingTarget -> $Source"
            continue
        }

        if ($Item.LinkType -eq "HardLink") {
            if (Test-SameFile $Source $Target) {
                Remove-Item -LiteralPath $Target -Force
            } else {
                Backup-Config $Target
            }
        } elseif ($Item.LinkType -and -not (Test-Path -LiteralPath $ExistingTarget)) {
            Remove-Item -LiteralPath $Target -Force
        } elseif ($Item.LinkType) {
            if ($BackupExisting -or $Link.CopyOnly) {
                Backup-Config $Target
            } else {
                $Conflicts += "linked elsewhere, left alone: $Target -> $ExistingTarget"
                continue
            }
        } elseif ((Test-Path -LiteralPath $Source -PathType Leaf) -and (Test-SameFile $Source $Target)) {
            Remove-Item -LiteralPath $Target -Force
        } else {
            if ($BackupExisting) {
                Backup-Config $Target
            } else {
                $Conflicts += "exists, left alone: $Target"
                continue
            }
        }
    }

    if (Test-Path -LiteralPath $Source -PathType Container) {
        New-Item -ItemType Junction -Path $Target -Target $Source -ErrorAction Stop | Out-Null
    } elseif ($UseFileLink) {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -ErrorAction Stop | Out-Null
    } else {
        if ($LoaderContent) {
            [IO.File]::WriteAllText($Target, $LoaderContent)
        } else {
            Copy-Item -LiteralPath $Source -Destination $Target -ErrorAction Stop
        }
        $CopyState[$Target] = $DesiredHash
        $CopyStateChanged = $true
    }

    $Created += "$Target -> $Source"
}

# Keep local safe-directory and Overleaf settings, then apply the shared Windows defaults.
$GitConfig = Join-Path $HOME ".gitconfig"
$GitItem = Get-Item -LiteralPath $GitConfig -Force -ErrorAction SilentlyContinue
if ($GitItem -and $GitItem.LinkType) {
    if (-not $BackupExisting) {
        $Conflicts += "Git config is linked; rerun with -BackupExisting to create a local include file: $GitConfig"
    } else {
        $GitContent = Get-Content -LiteralPath $GitConfig -Raw
        Backup-Config $GitConfig
        [IO.File]::WriteAllText($GitConfig, $GitContent)
        $GitItem = $null
    }
}
if (-not $GitItem -or -not $GitItem.LinkType) {
    if (-not (Test-Path -LiteralPath $GitConfig)) {
        New-Item -ItemType File -Path $GitConfig | Out-Null
    }
    $Includes = @(git config --global --no-includes --get-all include.path)
    $ManagedIncludes = @((Join-Path $Repo ".gitconfig").Replace('\', '/'),
        (Join-Path $HOME ".config\git\windows.gitconfig").Replace('\', '/'))
    $IncludeChanges = @()
    foreach ($Include in $ManagedIncludes) {
        $MatchingIncludes = @($Includes | Where-Object {
            $Normalized = $_.Replace('\', '/')
            if ($Normalized.StartsWith("~/")) { $Normalized = $HOME.Replace('\', '/') + $Normalized.Substring(1) }
            $Normalized -eq $Include
        })
        if ($MatchingIncludes.Count -ne 1) {
            $IncludeChanges += @{ Path = $Include; Existing = $MatchingIncludes }
        }
    }
    if ($IncludeChanges.Count -gt 0) {
        if ($GitItem) { Backup-Config $GitConfig $true }
        foreach ($Change in $IncludeChanges) {
            foreach ($Existing in @($Change.Existing | Select-Object -Unique)) {
                git config --global --fixed-value --unset-all include.path $Existing
                if ($LASTEXITCODE -ne 0) { throw "Could not deduplicate Git configuration include: $Existing" }
            }
            git config --global --add include.path $Change.Path
            if ($LASTEXITCODE -ne 0) { throw "Could not add Git configuration include: $($Change.Path)" }
        }
        $Created += "Git includes in $GitConfig"
    }
}

# Reuse plugins from the previous Windows profile without downloading them again.
$OldPlugins = Join-Path $HOME ".vim\plugged"
$Plugins = Join-Path $env:LOCALAPPDATA "nvim-data\plugged"
if ((Test-Path -LiteralPath $OldPlugins -PathType Container) -and -not (Test-Path -LiteralPath $Plugins)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Plugins) -Force | Out-Null
    New-Item -ItemType Junction -Path $Plugins -Target $OldPlugins | Out-Null
    $Created += "$Plugins -> $OldPlugins"
}

# Firefox reads user.js at startup; this works without policy-registry or Program Files access.
$FirefoxRoot = Join-Path $env:APPDATA "Mozilla\Firefox"
$ProfilesIni = Join-Path $FirefoxRoot "profiles.ini"
if (Test-Path -LiteralPath $ProfilesIni) {
    $Profiles = @()
    $CurrentProfile = $null
    foreach ($Line in Get-Content -LiteralPath $ProfilesIni) {
        $Line = $Line.Trim()
        if ($Line -match '^\[Profile\d+\]$') {
            $CurrentProfile = @{}
            $Profiles += $CurrentProfile
        } elseif ($Line.StartsWith("[")) {
            $CurrentProfile = $null
        } elseif ($null -ne $CurrentProfile -and $Line -match '^([^=]+)=(.*)$') {
            $CurrentProfile[$Matches[1]] = $Matches[2]
        }
    }
    $FirefoxPolicy = Get-Content -LiteralPath (Join-Path $Repo "firefox\policies.json") -Raw | ConvertFrom-Json
    $PreferenceLines = @($FirefoxPolicy.policies.Preferences.PSObject.Properties | ForEach-Object {
        $NameJson = $_.Name | ConvertTo-Json -Compress
        $ValueJson = $_.Value.Value | ConvertTo-Json -Compress
        "user_pref($NameJson, $ValueJson);"
    })
    $PreferenceBlock = "// BEGIN dotfiles session restore`n" + ($PreferenceLines -join "`n") + "`n// END dotfiles session restore`n"
    foreach ($Profile in $Profiles) {
        if (-not $Profile.Path) { continue }
        $ProfileDirectory = if ($Profile.IsRelative -eq "1") { Join-Path $FirefoxRoot $Profile.Path } else { $Profile.Path }
        if (-not (Test-Path -LiteralPath $ProfileDirectory -PathType Container)) { continue }
        $ProfileDirectory = [IO.Path]::GetFullPath($ProfileDirectory)
        if (-not $ProfileDirectory.StartsWith($HOME.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
            $Conflicts += "Firefox profile is outside the managed home directory: $ProfileDirectory"
            continue
        }
        $UserJs = Join-Path $ProfileDirectory "user.js"
        $ExistingUserJs = if (Test-Path -LiteralPath $UserJs) { [IO.File]::ReadAllText($UserJs) } else { "" }
        $OtherPreferences = [regex]::Replace($ExistingUserJs,
            '(?ms)^// BEGIN dotfiles session restore\r?\n.*?^// END dotfiles session restore(?:\r?\n|$)', "").TrimEnd()
        $UpdatedUserJs = if ($OtherPreferences) { "$OtherPreferences`n`n$PreferenceBlock" } else { $PreferenceBlock }
        if ($UpdatedUserJs -ne $ExistingUserJs) {
            if (Test-Path -LiteralPath $UserJs) { Backup-Config $UserJs $true }
            [IO.File]::WriteAllText($UserJs, $UpdatedUserJs)
            $Created += "$UserJs (session-restore preferences; restart Firefox to apply)"
        } else {
            $AlreadyLinked += "$UserJs (session-restore preferences)"
        }
    }
}

if ($CopyStateChanged) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $CopyStatePath) -Force | Out-Null
    $CopyState | ConvertTo-Json | Set-Content -LiteralPath $CopyStatePath -Encoding UTF8
}

Write-Host "Created or relinked:"
$Created | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "Already linked:"
$AlreadyLinked | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "Conflicts:"
$Conflicts | ForEach-Object { Write-Host "  $_" }

if ($Conflicts.Count -gt 0) {
    exit 1
}
