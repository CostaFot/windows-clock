Add-Type -AssemblyName System.Drawing

function ConvertTo-Ico {
    param($PngPath, $IcoPath)

    $png = [System.Drawing.Image]::FromFile((Resolve-Path $PngPath))
    $bmp = New-Object System.Drawing.Bitmap($png)
    $icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())

    $stream = [System.IO.File]::OpenWrite($IcoPath)
    $icon.Save($stream)
    $stream.Close()

    $icon.Dispose(); $bmp.Dispose(); $png.Dispose()
}

# Usage: ConvertTo-Ico -PngPath "clock.png" -IcoPath "clock.ico"
