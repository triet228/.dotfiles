$NoUpgrade = $args -contains "-NoUpgrade"
$EmptyRecycleBin = $args -contains "-EmptyRecycleBin"

function Test-Command {
    param($Name)
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Send-ToTrash {
    param([Parameter(ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]$Path)
    begin {
        Add-Type -AssemblyName Microsoft.VisualBasic
    }
    process {
        foreach ($item in $Path) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }
            $resolved = Resolve-Path -LiteralPath $item -ErrorAction SilentlyContinue
            if (-not $resolved) {
                Write-Warning "Not found: $item"
                continue
            }
            foreach ($r in $resolved) {
                if (Test-Path -LiteralPath $r.Path -PathType Container) {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($r.Path, "OnlyErrorDialogs", "SendToRecycleBin")
                } else {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($r.Path, "OnlyErrorDialogs", "SendToRecycleBin")
                }
            }
        }
    }
}

if (-not $NoUpgrade -and (Test-Command winget)) {
    winget source update
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}

if (Test-Command scoop) {
    scoop cleanup --all
    scoop cache rm --all
}

if (Test-Command choco) {
    choco cleanup -y
}

if (Test-Command conda) {
    conda clean --all --yes
}

if (Test-Command npm) {
    npm cache clean --force
}

if (Test-Command pip) {
    pip cache purge
}

# This computer keeps executable runtimes and downloaded models in ~/.cache.
# Clean only disposable caches; deleting the whole directory would remove those installations.
$CachePaths = @(
    (Join-Path $env:LOCALAPPDATA "Temp"),
    (Join-Path $env:LOCALAPPDATA "pip\Cache"),
    (Join-Path $env:LOCALAPPDATA "npm-cache"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\INetCache"),
    (Join-Path $HOME ".cache\lf"),
    (Join-Path $HOME ".cache\starship"),
    (Join-Path $HOME ".cache\yt-dlp")
)
foreach ($CachePath in $CachePaths) {
    $CacheItem = Get-Item -LiteralPath $CachePath -Force -ErrorAction SilentlyContinue
    if (-not $CacheItem -or -not $CacheItem.PSIsContainer -or
        ($CacheItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }

    $CacheRoot = (Resolve-Path -LiteralPath $CachePath).Path.TrimEnd('\') + '\'
    foreach ($Entry in @(Get-ChildItem -LiteralPath $CacheRoot -Force -ErrorAction SilentlyContinue)) {
        $EntryPath = [IO.Path]::GetFullPath($Entry.FullName)
        if (-not $EntryPath.StartsWith($CacheRoot, [StringComparison]::OrdinalIgnoreCase) -or
            ($Entry.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
        Remove-Item -LiteralPath $EntryPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

foreach ($personalPath in @(
    (Join-Path $HOME "Downloads"),
    (Join-Path $HOME "Pictures")
)) {
    if (Test-Path -LiteralPath $personalPath) {
        Get-ChildItem -LiteralPath $personalPath -Force -ErrorAction SilentlyContinue |
            ForEach-Object { Send-ToTrash -Path $_.FullName }
    }
}

if ($EmptyRecycleBin) {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

Clear-Host
if (Test-Command fastfetch) { fastfetch }
