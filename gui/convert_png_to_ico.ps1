# convert_png_to_ico.ps1 - converts viset_logo.png -> viset_icon.ico using System.Drawing
param()
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$png = Join-Path $scriptDir 'assets\viset_logo.png'
$ico = Join-Path $scriptDir 'assets\viset_icon.ico'
Add-Type -AssemblyName System.Drawing
if (-not (Test-Path $png)) { Write-Host "PNG not found: $png" -ForegroundColor Red; exit 1 }
# resize to 256x256 for good quality
$bmp = [System.Drawing.Image]::FromFile($png)
$thumb = New-Object System.Drawing.Bitmap 256,256
$g = [System.Drawing.Graphics]::FromImage($thumb)
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, 0, 0, 256, 256)
$g.Dispose()
$hIcon = $thumb.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = New-Object System.IO.FileStream($ico, [System.IO.FileMode]::Create)
$icon.Save($fs)
$fs.Close()
[System.Runtime.InteropServices.Marshal]::DestroyIcon($hIcon)
$thumb.Dispose(); $bmp.Dispose()
Write-Host "ICO generated: $ico" -ForegroundColor Green
