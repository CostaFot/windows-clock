param(
    [Parameter(Mandatory)][string]$PngPath,
    [Parameter(Mandatory)][string]$IcoPath
)

Add-Type -AssemblyName System.Drawing

$png = [System.Drawing.Bitmap]::new((Resolve-Path $PngPath).Path)

# Re-draw onto a fresh 32bpp ARGB bitmap to ensure correct color format
$bmp = New-Object System.Drawing.Bitmap($png.Width, $png.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($png, 0, 0, $png.Width, $png.Height)
$g.Dispose()
$png.Dispose()

# Save PNG bytes into a memory stream
$pngStream = New-Object System.IO.MemoryStream
$bmp.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$pngBytes = $pngStream.ToArray()
$pngStream.Dispose()

# Write ICO file: header + 1 directory entry + PNG data
$writer = New-Object System.IO.BinaryWriter([System.IO.File]::OpenWrite($IcoPath))

# ICO header
$writer.Write([uint16]0)       # reserved
$writer.Write([uint16]1)       # type: 1 = ICO
$writer.Write([uint16]1)       # image count

# Directory entry (16 bytes)
$writer.Write([byte]0)         # width  (0 = 256)
$writer.Write([byte]0)         # height (0 = 256)
$writer.Write([byte]0)         # color count
$writer.Write([byte]0)         # reserved
$writer.Write([uint16]1)       # color planes
$writer.Write([uint16]32)      # bits per pixel
$writer.Write([uint32]$pngBytes.Length)  # size of image data
$writer.Write([uint32]22)      # offset to image data (6 header + 16 entry)

# PNG data
$writer.Write($pngBytes)
$writer.Close()

Write-Host "Saved: $IcoPath"
