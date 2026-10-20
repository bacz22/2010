$ErrorActionPreference = 'Stop'

$html = Get-Content -Raw (Join-Path $PSScriptRoot 'index.html')
$assetNames = Get-ChildItem (Join-Path $PSScriptRoot 'assets') -Filter '*.jpg' |
  Sort-Object Name |
  ForEach-Object Name

$missing = @($assetNames | Where-Object { $html -notmatch [regex]::Escape("assets/$($_)") })
if ($missing.Count -gt 0) {
  throw "HTML chưa sử dụng các ảnh: $($missing -join ', ')"
}

$featuredImage = 'assets/3a60c2014b1acb44920b1.jpg'
$heroMatch = [regex]::Match($html, '<div class="hero-image"><img src="([^"]+)"')
$galleryMatch = [regex]::Match($html, '<div class="gallery">\s*<button[^>]+>\s*<img src="([^"]+)"')
if ($heroMatch.Groups[1].Value -ne $featuredImage -or $galleryMatch.Groups[1].Value -ne $featuredImage) {
  throw 'Ảnh 3a60c2014b1acb44920b1.jpg chưa đứng đầu ở ảnh chính và album.'
}

if ($html -match 'data:image') {
  throw 'HTML vẫn còn ảnh base64 nhúng trực tiếp.'
}

$required = @(
  'id="lightbox"',
  'id="lightboxImage"',
  'data-lightbox',
  'aria-label="Ảnh trước"',
  'aria-label="Ảnh tiếp theo"',
  "event.key === 'Escape'",
  "event.key === 'ArrowLeft'",
  "event.key === 'ArrowRight'"
)

$absent = @($required | Where-Object { -not $html.Contains($_) })
if ($absent.Count -gt 0) {
  throw "Thiếu chức năng lightbox: $($absent -join ', ')"
}

Write-Host "PASS: dùng đủ $($assetNames.Count) ảnh và có lightbox/điều hướng bàn phím."
