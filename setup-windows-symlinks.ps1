$Repo = $PSScriptRoot
$Documents = [Environment]::GetFolderPath("MyDocuments")

$Links = @(
    @{ Source = ".config\fastfetch"; Target = "$HOME\.config\fastfetch" },
    @{ Source = ".config\kitty"; Target = "$HOME\.config\kitty" },
    @{ Source = ".config\lf"; Target = "$HOME\.config\lf" },
    @{ Source = ".config\nvim"; Target = "$HOME\.config\nvim" },
    @{ Source = ".config\nvim"; Target = "$env:LOCALAPPDATA\nvim" },
    @{ Source = ".config\powershell"; Target = "$HOME\.config\powershell" },
    @{ Source = ".config\sxhkd"; Target = "$HOME\.config\sxhkd" },
    @{ Source = ".codex\AGENTS.md"; Target = "$HOME\.codex\AGENTS.md" },
    @{ Source = ".vimrc"; Target = "$HOME\.vimrc" },
    @{ Source = ".zshrc"; Target = "$HOME\.zshrc" },
    @{ Source = ".tmux.conf"; Target = "$HOME\.tmux.conf" },
    @{ Source = ".xinitrc"; Target = "$HOME\.xinitrc" },
    @{ Source = ".local\bin\bluetooth"; Target = "$HOME\.local\bin\bluetooth" },
    @{ Source = ".local\bin\project"; Target = "$HOME\.local\bin\project" },
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

    $LeftInfo = Get-Item -LiteralPath $Left -Force
    $RightInfo = Get-Item -LiteralPath $Right -Force
    return $LeftInfo.Length -eq $RightInfo.Length -and $LeftInfo.LastWriteTimeUtc -eq $RightInfo.LastWriteTimeUtc
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

foreach ($Link in $Links) {
    $Source = Join-Path $Repo $Link.Source
    $Target = $Link.Target

    if (-not (Test-Path -LiteralPath $Source)) {
        $Conflicts += "missing source: $Source"
        continue
    }

    $Parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        $Item = Get-Item -LiteralPath $Target -Force
        $ExistingTarget = Get-LinkTarget $Item

        if ($Item.LinkType -and $ExistingTarget -eq $Source) {
            $AlreadyLinked += $Target
            continue
        }

        if ($Item.LinkType -and (Test-RoutesToSource $ExistingTarget $Source)) {
            $AlreadyLinked += "$Target -> $ExistingTarget -> $Source"
            continue
        }

        if ($Item.LinkType -and -not (Test-Path -LiteralPath $ExistingTarget)) {
            Remove-Item -LiteralPath $Target -Force
        } elseif ($Item.LinkType) {
            $Conflicts += "linked elsewhere, left alone: $Target -> $ExistingTarget"
            continue
        } elseif ((Test-Path -LiteralPath $Source -PathType Leaf) -and (Test-SameFile $Source $Target)) {
            Remove-Item -LiteralPath $Target -Force
        } else {
            $Conflicts += "exists, left alone: $Target"
            continue
        }
    }

    if (Test-Path -LiteralPath $Source -PathType Container) {
        New-Item -ItemType Junction -Path $Target -Target $Source -ErrorAction Stop | Out-Null
    } else {
        New-Item -ItemType HardLink -Path $Target -Target $Source -ErrorAction Stop | Out-Null
    }

    $Created += "$Target -> $Source"
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
