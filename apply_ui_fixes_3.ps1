$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

$soldBadge = '<div class="badge-sold-out" style="position:absolute;top:10px;right:10px;z-index:2;background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;padding:3px 10px;border-radius:4px;text-transform:uppercase;letter-spacing:0.08em;">SOLD OUT</div>'
$bookedBadge = '<div class="badge-booked" style="position:absolute;top:10px;right:10px;z-index:2;background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;padding:3px 10px;border-radius:4px;text-transform:uppercase;letter-spacing:0.08em;">BOOKED</div>'

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        
        # 1. Delete brackets
        $content = [regex]::Replace($content, '(?i)<div class="hero-bracket.*?</div>', '')
        $content = [regex]::Replace($content, '(?i)<div class="corner.*?</div>', '')
        
        # 6. Move Badges to card-thumb
        $content = [regex]::Replace($content, '(?i)<div style="position:absolute;top:10px;right:10px;z-index:2;background:rgba\(147,51,234,0\.15\).*?</div>', '')
        $content = [regex]::Replace($content, '(?i)<div class="badge-sold-out".*?</div>', '')
        $content = [regex]::Replace($content, '(?i)<div class="badge-booked".*?</div>', '')

        $content = [regex]::Replace($content, '(?is)(data-status="sold"[^>]*>.*?<div class="card-thumb">)', "`$1`n" + $soldBadge)
        $content = [regex]::Replace($content, '(?is)(data-status="booked"[^>]*>.*?<div class="card-thumb">)', "`$1`n" + $bookedBadge)

        # Ensure video source is just hero.mp4
        $content = [regex]::Replace($content, '(?i)<source src=".*hero\.mp4"', '<source src="hero.mp4"')

        [IO.File]::WriteAllText($file, $content)
    }
}

# 3. View All Arsenal Button
$indexFile = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html"
if (Test-Path $indexFile) {
    $indexContent = [IO.File]::ReadAllText($indexFile)
    $indexContent = [regex]::Replace($indexContent, '(?is)<a href="views/accounts.html" class="btn-gold"[^>]*>View All Arsenal</a>', '<a href="views/accounts.html" class="btn-arsenal">View All Arsenal</a>')
    # Also replace it if it didn't have inline style
    $indexContent = [regex]::Replace($indexContent, '(?is)<a href="views/accounts.html" class="btn-gold">View All Arsenal</a>', '<a href="views/accounts.html" class="btn-arsenal">View All Arsenal</a>')
    [IO.File]::WriteAllText($indexFile, $indexContent)
}

$cssAppend = @"

/* --- UI FIXES BATCH 3 --- */
.hero-section {
  position: relative !important;
  overflow: hidden !important;
  min-height: 100vh !important;
}
.hero-section video {
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
  object-fit: cover !important;
  z-index: 0 !important;
  opacity: 0.4 !important;
}
.hero-section > *:not(video) {
  position: relative !important;
  z-index: 1 !important;
}

.btn-arsenal {
  display: inline-block !important;
  padding: 12px 32px !important;
  background: linear-gradient(90deg, #9333EA, #C084FC) !important;
  color: #fff !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 14px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 4px !important;
  text-decoration: none !important;
  box-shadow: 0 0 16px rgba(147,51,234,0.35) !important;
}

.card-thumb {
  position: relative !important;
  width: 100% !important;
  height: 220px !important;
  overflow: hidden !important;
  background: rgba(147,51,234,0.06) !important;
  border-radius: 8px 8px 0 0 !important;
}
.card-thumb img {
  width: 100% !important;
  height: 100% !important;
  object-fit: cover !important;
  display: block !important;
  font-size: 0 !important;
  color: transparent !important;
}

.card {
  display: flex !important;
  flex-direction: column !important;
  padding: 0 !important;
}
.card-body {
  padding: 16px !important;
  display: block !important;
  width: 100% !important;
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$cssContent = [IO.File]::ReadAllText($cssPath)
$cssContent += $cssAppend
[IO.File]::WriteAllText($cssPath, $cssContent)
