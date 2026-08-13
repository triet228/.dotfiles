$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
$env:EZA_COLORS = "di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"
$env:PYTHONWARNINGS = "ignore:OpenSSL 3's legacy provider failed to load"
$env:OLLAMA_HOST = "http://100.65.249.113:11434"

$Dotfiles = Join-Path $HOME "Projects\.dotfiles"
$LocalBin = Join-Path $HOME ".local\bin"
$RepoLocalBin = Join-Path $Dotfiles ".local\bin"
foreach ($PathToAdd in @($LocalBin, $RepoLocalBin, "$HOME\miniconda3\condabin", "$HOME\miniconda3\Scripts", "$HOME\miniconda3", "C:\Program Files\Neovim\bin")) {
    if ((Test-Path $PathToAdd) -and (($env:Path -split ";") -notcontains $PathToAdd)) {
        $env:Path = "$PathToAdd;$env:Path"
    }
}

Set-PSReadLineOption -EditMode Vi -BellStyle None -HistoryNoDuplicates:$true
$HasPSReadLinePrediction = (Get-Module PSReadLine).Version -ge [version]"2.1.0"
if ($HasPSReadLinePrediction -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    Set-PSReadLineOption -Colors @{ InlinePrediction = "`e[38;5;242m" } -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function AcceptSuggestion
}
if ($HasPSReadLinePrediction) {
    Set-PSReadLineKeyHandler -Key Tab -Function AcceptSuggestion
} else {
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}
Set-PSReadLineKeyHandler -Key Ctrl+f -Function Complete
Set-PSReadLineKeyHandler -Key Ctrl+a -Function SelectAll

function Invoke-FzfFileInsert {
    $cmd = if (Get-Command fd -ErrorAction SilentlyContinue) { { fd --type f --hidden --follow --exclude .git } } else { { Get-ChildItem -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object FullName } }
    $selected = & $cmd | fzf
    if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
}

function Invoke-FzfFileFromHome {
    $selected = fd --type f --hidden --follow --exclude .git . $HOME 2>$null | fzf
    if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
}

function Invoke-FzfCd {
    $selected = fd --type d --hidden --follow --exclude .git 2>$null | fzf
    if ($selected) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd `"$selected`"")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock { Invoke-FzfFileInsert }
    Set-PSReadLineKeyHandler -Key Ctrl+h -ScriptBlock { Invoke-FzfFileFromHome }
    Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock { Invoke-FzfCd }
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell --cmd z | Out-String)
}

$CondaHook = Join-Path $HOME "miniconda3\shell\condabin\conda-hook.ps1"
$CondaBat = Join-Path $HOME "miniconda3\condabin\conda.bat"
if (Test-Path $CondaHook) {
    . $CondaHook
} elseif (Test-Path $CondaBat) {
    function global:conda { & $CondaBat @args }
}

function global:vim { nvim @args }
function global:vi { nvim @args }
function global:open { Invoke-Item @args }
function global:d { Set-Location "$HOME\Downloads" }
function global:p { Set-Location "$HOME\Projects" }
function global:bin { Set-Location "$HOME\.local\bin" }
function global:h { z $HOME; ll }
function global:da { z "$HOME\Data"; ls }
function global:c { z "$HOME\Data\CLASSES"; ls }
function global:convert { magick @args }
function global:yy { (Get-Location).Path | Set-Clipboard }
function global:cpd { Copy-Item @args -Destination "$HOME\Downloads" -Recurse }
function global:cptd {
    if ($args.Count -eq 0) { Copy-Item * "$HOME\Downloads" -Recurse -Verbose }
    else { Copy-Item @args -Destination "$HOME\Downloads" -Recurse -Verbose }
}
function global:mvfd { Move-Item "$HOME\Downloads\*" . }
function global:mvtd { Move-Item @args -Destination "$HOME\Downloads" }

function global:trash {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Path)
    Add-Type -AssemblyName Microsoft.VisualBasic
    foreach ($item in $Path) {
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
function global:trash-put { trash @args }

function global:lff {
    $tmp = [System.IO.Path]::GetTempFileName()
    lf "-last-dir-path=$tmp" @args
    if (Test-Path $tmp) {
        $dir = Get-Content $tmp -Raw
        Remove-Item $tmp -Force
        $dir = $dir.Trim()
        if ($dir -and (Test-Path $dir -PathType Container)) { Set-Location $dir }
    }
}

function global:compress {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Files)
    if (-not $Files) {
        Write-Host "Usage: compress <file1.pdf> [file2.pdf] ..."
        return
    }
    foreach ($file in $Files) {
        if (-not (Test-Path $file -PathType Leaf)) {
            Write-Warning "Skipping '$file': file not found."
            continue
        }
        $out = [System.IO.Path]::Combine((Split-Path $file), ([System.IO.Path]::GetFileNameWithoutExtension($file) + "_compressed.pdf"))
        if (Get-Command gswin64c -ErrorAction SilentlyContinue) {
            gswin64c -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH "-sOutputFile=$out" "$file"
        } else {
            Write-Warning "Ghostscript is not installed, so '$file' was not compressed."
        }
    }
}

Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue

function global:ls {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza -l --sort=ext --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user @args
    } else {
        Get-ChildItem @args
    }
}
function global:ll {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza -la --sort=ext --icons --group-directories-first --time-style=long-iso --git @args
    } else {
        Get-ChildItem -Force @args
    }
}
function global:lss { eza --icons --tree --level=2 --group-directories-first @args }
function global:lsss { eza --icons --tree --level=3 --group-directories-first @args }
function global:lssss { eza --icons --tree --level=4 --group-directories-first @args }
function global:lsssss { eza --icons --tree --level=5 --group-directories-first @args }
function global:lssssss { eza --icons --tree --level=6 --group-directories-first @args }
function global:lsssssss { eza --icons --tree --level=7 --group-directories-first @args }
function global:lssssssss { eza --icons --tree --level=8 --group-directories-first @args }
function global:lsssssssss { eza --icons --tree --level=9 --group-directories-first @args }

function global:cd {
    if ($args.Count -eq 0) { Set-Location $HOME }
    elseif (Get-Command z -ErrorAction SilentlyContinue) { z @args }
    else { Set-Location @args }
    if ($?) { ls }
}

function global:prompt {
    $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, "~")
    $git = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ($branch) { $git = " on $branch" }
    }
    $conda = if ($env:CONDA_PROMPT_MODIFIER) { $env:CONDA_PROMPT_MODIFIER } else { "" }
    Write-Host ""
    Write-Host "$conda[$env:USERNAME@$env:COMPUTERNAME " -NoNewline -ForegroundColor Yellow
    Write-Host $path -NoNewline -ForegroundColor Cyan
    Write-Host "]" -NoNewline -ForegroundColor Yellow
    if ($git) { Write-Host $git -NoNewline -ForegroundColor Magenta }
    if ($path.Length -gt 20) { "`n>> " } else { "$ " }
}

if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}
