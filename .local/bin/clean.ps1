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

foreach ($cachePath in @(
    (Join-Path $env:LOCALAPPDATA "Temp"),
    (Join-Path $env:LOCALAPPDATA "pip\Cache"),
    (Join-Path $env:LOCALAPPDATA "npm-cache"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\INetCache"),
    (Join-Path $HOME ".cache")
)) {
    if (Test-Path -LiteralPath $cachePath) {
        Get-ChildItem -LiteralPath $cachePath -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
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
