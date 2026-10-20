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
$galleryMatch = [regex]::Match($html, '(?s)<div class="gallery">(.*?)</div>\s*<div class="quote-band">')
$galleryHtml = $galleryMatch.Groups[1].Value
if ($heroMatch.Groups[1].Value -ne $featuredImage) {
  throw 'Ảnh 3a60c2014b1acb44920b1.jpg chưa là ảnh chính.'
}
if ($galleryHtml.Contains($featuredImage)) {
  throw 'Ảnh chính vẫn còn xuất hiện trong Album của chúng mình.'
}
if (([regex]::Matches($galleryHtml, 'class="photo-card zoomable"')).Count -ne 9) {
  throw 'Album phải có đúng 9 ảnh sau khi loại ảnh chính.'
}
if ($html.Contains('lightboxCaption') -or $html -match '<figcaption') {
  throw 'Lightbox vẫn còn dòng chú thích ảnh.'
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
  "event.key === 'ArrowRight'",
  '@keyframes lightboxPop',
  '@keyframes heartFloat',
  'class="lightbox-hearts"',
  'classList.add(''is-switching'')'
)

$absent = @($required | Where-Object { -not $html.Contains($_) })
if ($absent.Count -gt 0) {
  throw "Thiếu chức năng lightbox: $($absent -join ', ')"
}

Write-Host 'PASS: ảnh chính tách khỏi album 9 ảnh, không chú thích và có hiệu ứng lightbox.'
