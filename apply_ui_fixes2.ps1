$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

$soldStyle = "position:absolute;top:10px;right:10px;z-index:2;background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;padding:3px 10px;border-radius:4px;text-transform:uppercase;letter-spacing:0.08em;"
$newSoldOverlay = "<div style=`"$soldStyle`">SOLD OUT</div>"

$bookedStyle = "position:absolute;top:10px;right:10px;z-index:2;background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;padding:3px 10px;border-radius:4px;text-transform:uppercase;letter-spacing:0.08em;"
$newBookedOverlay = "<div style=`"$bookedStyle`">BOOKED</div>"

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        
        $content = [Text.RegularExpressions.Regex]::Replace($content, '(?i)<div style="position:absolute;top:10px;right:10px;z-index:10;pointer-events:none;">\s*<span.*?>SOLD OUT</span>\s*</div>', $newSoldOverlay)
        $content = [Text.RegularExpressions.Regex]::Replace($content, '(?i)<div style="position:absolute;top:10px;right:10px;z-index:10;pointer-events:none;">\s*<span.*?>BOOKED</span>\s*</div>', $newBookedOverlay)

        [IO.File]::WriteAllText($file, $content)
    }
}

$indexFile = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html"
$indexContent = [IO.File]::ReadAllText($indexFile)

$indexContent = [Text.RegularExpressions.Regex]::Replace($indexContent, '(?s)<div class="vouches-cta.*?</div>', '')

$heroTarget = '<header class="hero-section">'
$heroReplace = @"
<header class="hero-section" style="position:relative; overflow:hidden;">
<video autoplay muted loop playsinline style="position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover;z-index:0;opacity:0.35">
  <source src="hero.mp4" type="video/mp4">
</video>
"@
$indexContent = $indexContent.Replace($heroTarget, $heroReplace)

[IO.File]::WriteAllText($indexFile, $indexContent)

$cssAppend = @"

/* --- UI FIXES BATCH 2 --- */
.hero-section > *:not(video) {
  position: relative !important;
  z-index: 1 !important;
}

nav {
  display: flex !important;
  border-bottom: 1px solid rgba(255,255,255,0.05) !important;
}
.nav-links {
  margin-right: auto !important;
  margin-left: 2rem !important;
}
nav::after {
  display: none !important;
}

.card-thumb {
  width: 100% !important;
  height: 200px !important;
  overflow: hidden !important;
  border-radius: 8px 8px 0 0 !important;
  background: rgba(147,51,234,0.08) !important;
}
.card-thumb img {
  width: 100% !important;
  height: 100% !important;
  object-fit: cover !important;
}

.card {
  padding: 0 !important;
  background: rgba(147,51,234,0.04) !important;
  border: 1px solid rgba(147,51,234,0.15) !important;
  border-radius: 8px !important;
}
.card-body {
  padding: 16px !important;
}
.card-meta span, .card-meta {
  font-size: 10px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  color: #9333EA !important;
  margin-bottom: 6px !important;
  display: block !important;
  font-family: 'Inter', sans-serif !important;
}
.card-name {
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 18px !important;
  font-weight: 900 !important;
  text-transform: uppercase !important;
  color: #ffffff !important;
  margin-bottom: 8px !important;
  line-height: 1.1 !important;
}
.card-desc {
  font-size: 12px !important;
  color: rgba(255,255,255,0.5) !important;
  line-height: 1.6 !important;
}
.card-tags .tag, .card-pill {
  background: rgba(147,51,234,0.08) !important;
  border: 1px solid rgba(147,51,234,0.2) !important;
  color: #C084FC !important;
  font-size: 10px !important;
  padding: 3px 8px !important;
  border-radius: 4px !important;
  display: inline-block !important;
  margin-top: 8px !important;
}
.card-price {
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 24px !important;
  font-weight: 900 !important;
  color: #9333EA !important;
  text-shadow: 0 0 14px rgba(147,51,234,0.4) !important;
}
.grid {
  gap: 20px !important;
}
.card::after {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 2px !important;
  background: linear-gradient(90deg, #9333EA, #C084FC) !important;
  box-shadow: 0 0 8px rgba(147,51,234,0.3) !important;
  border-radius: 8px 8px 0 0 !important;
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$cssContent = [IO.File]::ReadAllText($cssPath)
$cssContent += $cssAppend
[IO.File]::WriteAllText($cssPath, $cssContent)
