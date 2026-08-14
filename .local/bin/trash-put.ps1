Add-Type -AssemblyName Microsoft.VisualBasic

foreach ($Path in $args) {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        continue
    }

    $Resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $Resolved) {
        Write-Warning "Not found: $Path"
        continue
    }

    foreach ($Item in $Resolved) {
        if (Test-Path -LiteralPath $Item.Path -PathType Container) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Item.Path, "OnlyErrorDialogs", "SendToRecycleBin")
        } else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Item.Path, "OnlyErrorDialogs", "SendToRecycleBin")
        }
    }
}
