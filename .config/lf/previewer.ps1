param([string]$Path)

if (-not $Path -or -not (Test-Path -LiteralPath $Path)) {
    exit 0
}

$item = Get-Item -LiteralPath $Path -Force
if ($item.PSIsContainer) {
    Get-ChildItem -LiteralPath $item.FullName -Force |
        Sort-Object @{Expression = 'PSIsContainer'; Descending = $true}, Extension, Name |
        Select-Object -First 120 -ExpandProperty Name
    exit 0
}

$extension = $item.Extension.ToLowerInvariant()
switch ($extension) {
    '.pdf' {
        Write-Output "PDF: $($item.Name)"
        Write-Output "$([math]::Round($item.Length / 1MB, 2)) MB"
        exit 0
    }
    { $_ -in '.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.ico' } {
        Write-Output "Image: $($item.Name)"
        Write-Output "$([math]::Round($item.Length / 1KB, 2)) KB"
        exit 0
    }
    { $_ -in '.zip', '.tar', '.gz', '.tgz', '.7z', '.rar' } {
        Write-Output "Archive: $($item.Name)"
        Write-Output "$([math]::Round($item.Length / 1MB, 2)) MB"
        exit 0
    }
}

try {
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        bat --color=always --style=plain --line-range :200 -- "$($item.FullName)"
        exit 0
    }

    Get-Content -LiteralPath $item.FullName -TotalCount 200 -ErrorAction Stop
} catch {
    Write-Output "$($item.Name)"
    Write-Output "$([math]::Round($item.Length / 1KB, 2)) KB"
}
