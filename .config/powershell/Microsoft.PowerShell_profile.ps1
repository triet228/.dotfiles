$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
# Keep gh's existing Windows login when other tools use the shared XDG directory.
$GitHubWindowsConfig = Join-Path $env:APPDATA "GitHub CLI"
if (-not $env:GH_CONFIG_DIR -and (Test-Path -LiteralPath (Join-Path $GitHubWindowsConfig "hosts.yml")) -and
    -not (Test-Path -LiteralPath (Join-Path $env:XDG_CONFIG_HOME "gh\hosts.yml"))) {
    $env:GH_CONFIG_DIR = $GitHubWindowsConfig
}
$env:EZA_COLORS = "di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"
$env:PYTHONWARNINGS = "ignore:OpenSSL 3's legacy provider failed to load"
$env:OLLAMA_HOST = "http://127.0.0.1:11434"
$env:LS_COLORS = "di=1;96:ow=1;96:tw=1;96:st=1;96:fi=0;37:ln=1;95:or=1;91:ex=1;92:*.py=1;93:*.md=1;97:*.json=1;96:*.tex=1;93"

# Redirected commands and background shells should start without terminal output.
$InteractiveTerminal = $Host.Name -eq "ConsoleHost" -and $env:TERM -ne "dumb" -and
    -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected

$LocalBin = Join-Path $HOME ".local\bin"
$HugoBin = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Hugo.Hugo*\hugo.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty DirectoryName
$ProfilePaths = @($LocalBin, "$env:LOCALAPPDATA\Microsoft\WinGet\Links", "$HOME\go\bin", "$HOME\miniconda3\condabin", "C:\Program Files\Neovim\bin", "C:\Program Files\Go\bin", $HugoBin)
# An already-running terminal app may have an older PATH than newly installed user packages.
$ProfilePaths += [Environment]::GetEnvironmentVariable("Path", "User") -split ";"
foreach ($PathToAdd in $ProfilePaths) {
    if (-not $PathToAdd) { continue }
    $PathToAdd = [Environment]::ExpandEnvironmentVariables($PathToAdd.Trim().Trim('"'))
    if ((Test-Path -LiteralPath $PathToAdd -PathType Container) -and (($env:Path -split ";") -notcontains $PathToAdd)) {
        $env:Path = "$PathToAdd;$env:Path"
    }
}

if ($InteractiveTerminal -and (Get-Module -ListAvailable PSReadLine)) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Vi -BellStyle None -HistoryNoDuplicates
    $HasPSReadLinePrediction = (Get-Module PSReadLine).Version -ge [version]"2.1.0"
    if ($HasPSReadLinePrediction) {
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        if ((Get-Command Set-PSReadLineOption).Parameters.ContainsKey("PredictionViewStyle")) {
            Set-PSReadLineOption -PredictionViewStyle InlineView
        }
        Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]27)[38;5;242m" } -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion
        Set-PSReadLineKeyHandler -Key Ctrl+e -Function AcceptSuggestion
        Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
            param($Key, $Arg)
            $Before = $null
            $BeforeCursor = 0
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Before, [ref]$BeforeCursor)
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($Key, $Arg)
            $After = $null
            $AfterCursor = 0
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$After, [ref]$AfterCursor)
            if ($Before -eq $After -and $BeforeCursor -eq $AfterCursor) {
                [Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete($Key, $Arg)
            }
        }
    } else {
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    }
    Set-PSReadLineKeyHandler -Key Ctrl+f -Function Complete
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function SelectAll
    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        $line = $null
        $cursor = 0
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($line -match '^\s*clean(\s|$)') {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("& $line")
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

function Get-FuzzyFiles {
    param($Root = ".")
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd --type f --hidden --follow --exclude .git . $Root
    } elseif (Get-Command rg -ErrorAction SilentlyContinue) {
        rg --files --hidden -g '!.git' -- $Root
    } else {
        Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object FullName
    }
}

function Invoke-FzfFileInsert {
    $selected = Get-FuzzyFiles | fzf
    if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
}

function Invoke-FzfFileFromHome {
    $selected = Get-FuzzyFiles $HOME | fzf
    if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
}

function Invoke-FzfCd {
    $directories = if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd --type d --hidden --follow --exclude .git
    } else {
        Get-ChildItem -Directory -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object FullName
    }
    $selected = $directories | fzf
    if ($selected) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd `"$selected`"")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

function Invoke-FzfHistory {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (-not (Test-Path $historyPath)) { return }

    $line = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $selected = Get-Content $historyPath |
        Where-Object { $_.Trim() } |
        Select-Object -Unique |
        fzf --tac --no-sort --query $line

    if ($selected) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
    }
}

if ($InteractiveTerminal -and (Get-Module PSReadLine) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock { Invoke-FzfFileInsert }
    Set-PSReadLineKeyHandler -Key Ctrl+r -ViMode Insert -ScriptBlock { Invoke-FzfHistory }
    Set-PSReadLineKeyHandler -Key Ctrl+h -ScriptBlock { Invoke-FzfFileFromHome }
    Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock { Invoke-FzfCd }
}

$CondaRoots = @($env:_CONDA_ROOT, "$HOME\miniconda3", "$HOME\anaconda3", "$env:LOCALAPPDATA\miniforge3", "$env:LOCALAPPDATA\miniconda3", "$env:ProgramData\miniconda3", "$env:ProgramData\Anaconda3")
foreach ($CondaRoot in $CondaRoots) {
    if (-not $CondaRoot) { continue }
    $CondaExe = Join-Path $CondaRoot "Scripts\conda.exe"
    if (Test-Path -LiteralPath $CondaExe) {
        (& $CondaExe shell.powershell hook | Out-String) | Invoke-Expression
        break
    }
}

function global:Test-Command {
    param($Name)
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function global:Send-ToTrash {
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

Remove-Item Alias:vim, Alias:vi, Alias:lf, Alias:ll, Alias:h -Force -ErrorAction Ignore
function global:vim { nvim @args }
function global:vi { nvim @args }
function global:open { Invoke-Item @args }
function global:d { Set-Location "$HOME\Downloads" }
function global:p { Set-Location "$HOME\Projects" }
function global:bin { Set-Location "$HOME\.local\bin" }
function global:h { cd $HOME }
function global:da { cd "$HOME\Data" }
function global:c { cd "$HOME\Data\CLASSES" }
function global:convert {
    if (Test-Command magick) { magick @args }
    else { Write-Error "ImageMagick is not installed or not on PATH." }
}
function global:yy { (Get-Location).Path | Set-Clipboard }
function global:cpd { Copy-Item @args -Destination "$HOME\Downloads" -Recurse }
function global:cptd {
    if ($args.Count -eq 0) { Copy-Item * "$HOME\Downloads" -Recurse -Verbose }
    else { Copy-Item @args -Destination "$HOME\Downloads" -Recurse -Verbose }
}
function global:mvfd { Move-Item "$HOME\Downloads\*" . }
function global:mvtd { Move-Item @args -Destination "$HOME\Downloads" }

function global:trash { Send-ToTrash @args }
function global:trash-put { trash @args }

function global:clean {
    & (Join-Path $LocalBin "clean.ps1") @args
}

function global:lff {
    $lfCommand = Get-Command lf.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $lfCommand) { Write-Error "lf.exe is not installed or not on PATH."; return }
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & $lfCommand.Source "-last-dir-path=$tmp" @args
        $dir = Get-Content $tmp -Raw
        if ($dir) {
            $dir = $dir.Trim()
            if (Test-Path -LiteralPath $dir -PathType Container) { Set-Location -LiteralPath $dir }
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}
function global:lf { lff @args }

function global:touch {
    param($Path)
    if (Test-Path -LiteralPath $Path) {
        (Get-Item -LiteralPath $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

function global:pimg {
    param($Path = (Join-Path $env:TEMP "clipboard-image.png"))
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if (-not $image) { Write-Error "No image found in clipboard."; return }
    try {
        $image.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
        Set-Clipboard -Value $Path
        Write-Host "Saved clipboard image: $Path"
    } finally {
        $image.Dispose()
    }
}

function global:tools {
    foreach ($name in @("git", "gh", "conda", "nvim", "lf.exe", "eza", "fzf", "zoxide", "rg", "starship", "fastfetch", "bat", "fd", "magick", "gswin64c", "pdfcpu")) {
        $command = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
        $location = if ($command) { if ($command.Source) { $command.Source } else { $command.CommandType } } else { "MISSING" }
        "$name -> $location"
    }
}

function global:compress {
    param([Parameter(ValueFromRemainingArguments = $true)]$Files)
    if (-not $Files) {
        Write-Host "Usage: compress <file1.pdf> [file2.pdf] ..."
        return
    }
    foreach ($file in $Files) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            Write-Warning "Skipping '$file': file not found."
            continue
        }
        $source = (Get-Item -LiteralPath $file).FullName
        $out = Join-Path ([IO.Path]::GetDirectoryName($source)) ([IO.Path]::GetFileNameWithoutExtension($source) + "_compressed.pdf")
        if (Get-Command gswin64c -ErrorAction SilentlyContinue) {
            # Keep decimal switches and filenames as literal native arguments in both PowerShell versions.
            $ghostscriptOptions = @('-sDEVICE=pdfwrite', '-dCompatibilityLevel=1.4', '-dPDFSETTINGS=/ebook', '-dNOPAUSE', '-dQUIET', '-dBATCH', "-sOutputFile=$out", $source)
            & gswin64c @ghostscriptOptions
            if ($LASTEXITCODE -ne 0) { Write-Error "Ghostscript failed to compress '$source'." }
        } elseif (Get-Command pdfcpu -ErrorAction SilentlyContinue) {
            # pdfcpu is portable and provides a non-admin fallback on managed Windows computers.
            & pdfcpu optimize $source $out
            if ($LASTEXITCODE -ne 0) { Write-Error "pdfcpu failed to optimize '$source'." }
        } else {
            Write-Warning "Neither Ghostscript nor pdfcpu is installed, so '$file' was not compressed."
        }
    }
}

Remove-Item Alias:ls -Force -ErrorAction Ignore
Remove-Item Alias:cd -Force -ErrorAction Ignore

function global:ls {
    if (Test-Command eza) {
        # An explicit directory also makes listings work when the shell's input is redirected.
        $ListArguments = if ($args.Count) { $args } else { @('.') }
        eza -l --sort=ext --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user @ListArguments
    } else {
        Get-ChildItem @args
    }
}
function global:ll {
    if (Test-Command eza) {
        $ListArguments = if ($args.Count) { $args } else { @('.') }
        eza -la --sort=ext --icons --group-directories-first --time-style=long-iso --git @ListArguments
    } else {
        Get-ChildItem -Force @args
    }
}

function global:Invoke-TreeList {
    param($Level)
    if (Test-Command eza) {
        $ListArguments = if ($args.Count) { $args } else { @('.') }
        eza --icons --tree --level=$Level --group-directories-first @ListArguments
    } else {
        Get-ChildItem -Recurse -Depth $Level @args
    }
}
function global:lss { Invoke-TreeList 2 @args }
function global:lsss { Invoke-TreeList 3 @args }
function global:lssss { Invoke-TreeList 4 @args }
function global:lsssss { Invoke-TreeList 5 @args }
function global:lssssss { Invoke-TreeList 6 @args }
function global:lsssssss { Invoke-TreeList 7 @args }
function global:lssssssss { Invoke-TreeList 8 @args }
function global:lsssssssss { Invoke-TreeList 9 @args }

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

if ($InteractiveTerminal -and (Get-Command zoxide -ErrorAction SilentlyContinue)) {
    Remove-Variable __zoxide_hooked -Scope Global -ErrorAction Ignore
    Invoke-Expression (& zoxide init powershell --cmd z | Out-String)
}

function global:Invoke-Starship-PreCommand {
    $leaf = Split-Path -Leaf (Get-Location)
    $Host.UI.RawUI.WindowTitle = if ($leaf) { $leaf } else { (Get-Location).Path }
}

if ($InteractiveTerminal -and (Test-Command starship)) {
    Invoke-Expression (& starship init powershell | Out-String)
}

if ($InteractiveTerminal -and (Test-Command fastfetch)) {
    fastfetch
}
