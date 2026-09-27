Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class FomPx {
  public static Rectangle Bounds(Bitmap bmp, int threshold) {
    int w = bmp.Width, h = bmp.Height;
    int minX = w, minY = h, maxX = 0, maxY = 0;
    var rect = new Rectangle(0, 0, w, h);
    var data = bmp.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
    int stride = data.Stride;
    byte[] buf = new byte[stride * h];
    System.Runtime.InteropServices.Marshal.Copy(data.Scan0, buf, 0, buf.Length);
    bmp.UnlockBits(data);
    for (int y = 0; y < h; y++) {
      int row = y * stride;
      for (int x = 0; x < w; x++) {
        int i = row + x * 4;
        int b = buf[i], g = buf[i + 1], r = buf[i + 2];
        if (r > threshold || g > threshold) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < minX) return new Rectangle(0, 0, w, h);
    return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
  }
  public static Bitmap Knockout(Bitmap src, int threshold) {
    var dst = new Bitmap(src.Width, src.Height, PixelFormat.Format32bppArgb);
    var r1 = new Rectangle(0, 0, src.Width, src.Height);
    var sdata = src.LockBits(r1, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
    var ddata = dst.LockBits(r1, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
    int n = Math.Abs(sdata.Stride) * src.Height;
    byte[] buf = new byte[n];
    System.Runtime.InteropServices.Marshal.Copy(sdata.Scan0, buf, 0, n);
    src.UnlockBits(sdata);
    int stride = ddata.Stride;
    for (int y = 0; y < src.Height; y++) {
      int row = y * stride;
      for (int x = 0; x < src.Width; x++) {
        int i = row + x * 4;
        if (buf[i] < threshold && buf[i + 1] < threshold && buf[i + 2] < threshold) buf[i + 3] = 0;
      }
    }
    System.Runtime.InteropServices.Marshal.Copy(buf, 0, ddata.Scan0, n);
    dst.UnlockBits(ddata);
    return dst;
  }
}
"@

$root = "E:\pack\bsc\4"
$assets = "C:\Users\Alita\.cursor\projects\e-pack-bsc-4\assets"
$hero = Join-Path $assets "fom-hero.png"
$word = Join-Path $assets "fom-wordmark.png"
$mark = Join-Path $assets "fom-square-mark.png"
$chart = Join-Path $assets "fom-square-chart.png"
$city = Join-Path $assets "fom-square-city.png"
$globe = Join-Path $assets "fom-square-globe.png"

function Save-Jpeg([System.Drawing.Image]$img, [string]$path) {
  $dir = Split-Path $path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $tmp = "$path.tmp.jpg"
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]90)
  $img.Save($tmp, $codec, $ep)
  if (Test-Path $path) { Remove-Item $path -Force }
  Move-Item $tmp $path -Force
}

function Save-Png([System.Drawing.Image]$img, [string]$path) {
  $tmp = "$path.tmp.png"
  $img.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
  if (Test-Path $path) { Remove-Item $path -Force }
  Move-Item $tmp $path -Force
}

function New-Cover([string]$srcPath, [int]$tw, [int]$th) {
  $src = [System.Drawing.Image]::FromFile($srcPath)
  $bmp = New-Object System.Drawing.Bitmap $tw, $th
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.Clear([System.Drawing.Color]::Black)
  $scale = [Math]::Max($tw / $src.Width, $th / $src.Height)
  $sw = [int]($src.Width * $scale)
  $sh = [int]($src.Height * $scale)
  $x = [int](($tw - $sw) / 2)
  $y = [int](($th - $sh) / 2)
  $g.DrawImage($src, $x, $y, $sw, $sh)
  $g.Dispose()
  $src.Dispose()
  return $bmp
}

function Write-Cover([string]$srcPath, [string]$dest, [int]$tw, [int]$th) {
  $bmp = New-Cover $srcPath $tw $th
  if ($dest.ToLower().EndsWith(".png")) { Save-Png $bmp $dest } else { Save-Jpeg $bmp $dest }
  $bmp.Dispose()
  Write-Output "cover $tw x $th -> $dest"
}

# Crop wordmark to the gold pixels and knock out the black background.
$srcW = New-Object System.Drawing.Bitmap $word
$box = [FomPx]::Bounds($srcW, 40)
$pad = 18
$minX = [Math]::Max(0, $box.X - $pad)
$minY = [Math]::Max(0, $box.Y - $pad)
$maxX = [Math]::Min($srcW.Width - 1, $box.Right + $pad)
$maxY = [Math]::Min($srcW.Height - 1, $box.Bottom + $pad)
$cw = $maxX - $minX + 1
$ch = $maxY - $minY + 1
$crop = $srcW.Clone((New-Object System.Drawing.Rectangle $minX, $minY, $cw, $ch), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$srcW.Dispose()
$clear = [FomPx]::Knockout($crop, 22)
$crop.Dispose()
$logoNav = Join-Path $root "wp-content\themes\Divi\images\logo.png"
$logoWide = Join-Path $root "wp-content\uploads\2025\02\logo-1-e1744717578807.png"
Save-Png $clear $logoNav
Save-Png $clear $logoWide
Write-Output "wordmark $($clear.Width)x$($clear.Height)"
$clear.Dispose()

# Wide covers from the hero.
$wides = @(
  @{ p = "wp-content\uploads\2025\04\broccoli-cyberpunk-city-hq-02-placeholder.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\Ecosystem-cover-02.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-MB-00C.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-MB-00C-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-MB-00C-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-MB-00C-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\04\F3B_Giggle_EP02_00A.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\F3B_Giggle_EP02_00A-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\04\F3B_Giggle_EP02_00A-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\04\F3B_Giggle_EP02_00A-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP003_00A04.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP003_00A04-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP003_00A04-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP003_00A04-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP004_00B.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP004_00B-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP004_00B-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\04\F3B_Story_EP004_00B-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP005_00A.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP005_00A-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP005_00A-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP005_00A-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP006_00A.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP006_00A-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP006_00A-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP006_00A-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP007_00_A.jpg"; w = 1600; h = 900 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP007_00_A-1280x720.jpg"; w = 1280; h = 720 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP007_00_A-980x551.jpg"; w = 980; h = 551 },
  @{ p = "wp-content\uploads\2025\05\F3B_Story_EP007_00_A-480x270.jpg"; w = 480; h = 270 },
  @{ p = "wp-content\uploads\2025\04\giggle-book.jpg"; w = 600; h = 427 },
  @{ p = "wp-content\uploads\2025\04\giggle-book-480x342.jpg"; w = 480; h = 342 }
)
foreach ($item in $wides) {
  Write-Cover $hero (Join-Path $root $item.p) $item.w $item.h
}

$scenes = @($chart, $city, $globe)
$gallery = @(
  "wp-content\uploads\2025\04\F3B-Build-01.jpg",
  "wp-content\uploads\2025\04\F3B_Cyberpunk-A03.jpg",
  "wp-content\uploads\2025\04\F3B_Moon_01.jpg",
  "wp-content\uploads\2025\04\F3B_Farmer_03.jpg",
  "wp-content\uploads\2025\04\F3B_GM_D01.jpg",
  "wp-content\uploads\2025\04\F3B_Poker_01.jpg",
  "wp-content\uploads\2025\04\F3B-skateboard-01.jpg",
  "wp-content\uploads\2025\04\F3B_Build_C01.jpg",
  "wp-content\uploads\2025\04\F3B_Learn01.jpg",
  "wp-content\uploads\2025\04\F3B-Car-01.jpg",
  "wp-content\uploads\2025\04\F3B_Jetski_02.jpg",
  "wp-content\uploads\2025\04\F3B_Build_B01.jpg",
  "wp-content\uploads\2025\04\F3B-rocket-01.jpg",
  "wp-content\uploads\2025\04\F3B-Chef-01.jpg",
  "wp-content\uploads\2025\04\F3B_Build_D01.jpg",
  "wp-content\uploads\2025\04\F3B-Beach-01.jpg",
  "wp-content\uploads\2025\04\iphone-binance-wallet-03.jpg"
)
$i = 0
foreach ($rel in $gallery) {
  Write-Cover $scenes[$i % $scenes.Length] (Join-Path $root $rel) 600 600
  $i++
}
Write-Cover $scenes[1] (Join-Path $root "wp-content\uploads\2025\04\F3B_Cyberpunk-A03-480x480.jpg") 480 480
Write-Cover $scenes[0] (Join-Path $root "wp-content\uploads\2025\04\iphone-binance-wallet-03-480x480.jpg") 480 480

# Square name lockup for welcome, social, and holding hero.
$marks = @(
  @{ p = "wp-content\uploads\2025\03\cropped-Broccoli_logoCircle_500px.png"; s = 512 },
  @{ p = "wp-content\uploads\2025\03\cropped-Broccoli_logoCircle_500px-480x480.png"; s = 480 },
  @{ p = "wp-content\uploads\2025\02\broccoli-favicon.png"; s = 512 },
  @{ p = "wp-content\uploads\2025\02\broccoli-favicon-480x480.png"; s = 480 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-x-Binance-Square-01.jpg"; s = 600 },
  @{ p = "wp-content\uploads\2025\04\Broccoli-x-Binance-Square-01-480x480.jpg"; s = 480 },
  @{ p = "wp-content\uploads\2025\04\bsc-chain-winner-01.jpg"; s = 600 },
  @{ p = "wp-content\uploads\2025\04\bsc-chain-winner-01-480x480.jpg"; s = 480 }
)
foreach ($item in $marks) {
  $dest = Join-Path $root $item.p
  $bmp = New-Cover $mark $item.s $item.s
  if ($dest.ToLower().EndsWith(".png")) { Save-Png $bmp $dest } else { Save-Jpeg $bmp $dest }
  $bmp.Dispose()
  Write-Output "mark $($item.s) -> $($item.p)"
}

# Small icons: diamond only, cropped from the top of the square mark.
$srcM = New-Object System.Drawing.Bitmap $mark
$topH = [int]($srcM.Height * 0.62)
$top = $srcM.Clone((New-Object System.Drawing.Rectangle 0, 0, $srcM.Width, $topH), $srcM.PixelFormat)
$srcM.Dispose()
$dbox = [FomPx]::Bounds($top, 80)
$dx1 = $dbox.X; $dy1 = $dbox.Y; $dx2 = $dbox.Right; $dy2 = $dbox.Bottom
$side = [Math]::Max($dx2 - $dx1, $dy2 - $dy1) + 80
if ($side -gt $top.Width) { $side = $top.Width }
if ($side -gt $top.Height) { $side = $top.Height }
$cx = [int](($dx1 + $dx2) / 2)
$cy = [int](($dy1 + $dy2) / 2)
$sx = [Math]::Max(0, $cx - [int]($side / 2))
$sy = [Math]::Max(0, $cy - [int]($side / 2))
if ($sx + $side -gt $top.Width) { $sx = [Math]::Max(0, $top.Width - $side) }
if ($sy + $side -gt $top.Height) { $sy = [Math]::Max(0, $top.Height - $side) }
$icon = $top.Clone((New-Object System.Drawing.Rectangle $sx, $sy, $side, $side), $top.PixelFormat)
$top.Dispose()
$iconTmp = Join-Path $env:TEMP "fom-diamond.png"
Save-Png $icon $iconTmp
$icon.Dispose()
foreach ($size in @(32, 180, 192, 270)) {
  $name = "cropped-Broccoli_logoCircle_500px-${size}x${size}.png"
  $dest = Join-Path $root "wp-content\uploads\2025\03\$name"
  Write-Cover $iconTmp $dest $size $size
}
Write-Output "done"
