$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

$newSoldOverlay = '<div style="position:absolute;top:10px;right:10px;z-index:10;pointer-events:none;"><span style="background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;padding:3px 10px;border-radius:4px;">SOLD OUT</span></div>'
$newBookedOverlay = '<div style="position:absolute;top:10px;right:10px;z-index:10;pointer-events:none;"><span style="background:rgba(147,51,234,0.15);border:1px solid rgba(147,51,234,0.4);color:#C084FC;font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;padding:3px 10px;border-radius:4px;">BOOKED</span></div>'

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        
        # Replace overlays exactly
        $content = [Text.RegularExpressions.Regex]::Replace($content, '(?i)<div style="position:absolute;inset:0;background:rgba\(0,0,0,0\.6\).*?>\s*<span.*?>SOLD OUT</span>\s*</div>', $newSoldOverlay)
        $content = [Text.RegularExpressions.Regex]::Replace($content, '(?i)<div style="position:absolute;inset:0;background:rgba\(0,0,0,0\.6\).*?>\s*<span.*?>BOOKED</span>\s*</div>', $newBookedOverlay)

        # Footer Logo
        $content = $content.Replace('<div class="foot-logo">DIESYT STORE</div>', '<div class="foot-logo">DIESYT <span style="color:#9333EA;">STORE</span></div>')

        [IO.File]::WriteAllText($file, $content)
    }
}

$cssAppend = @"

/* --- UI FIXES --- */
/* 2. Card Buy Button */
.card-buy {
  width: auto !important;
  padding: 10px 20px !important;
  border-radius: 4px !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 12px !important;
  letter-spacing: 0.08em !important;
  text-transform: uppercase !important;
  box-shadow: 0 0 14px rgba(147,51,234,0.3) !important;
  background: linear-gradient(90deg, #9333EA, #C084FC) !important;
  color: #fff !important;
  border: none !important;
}

/* 3. Footer Logo */
.foot-logo {
  background: none !important;
  color: #fff !important;
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
  padding: 0 !important;
  -webkit-text-fill-color: initial !important;
}

/* 4. Vouch Dividers */
.vouch-card {
  border-bottom: 1px solid rgba(255,255,255,0.05) !important;
}
.vouch-line {
  background: rgba(255,255,255,0.05) !important;
}

/* 5. Dominate Shine */
.cta-title .shine, .shine {
  color: #9333EA !important;
  text-shadow: 0 0 20px rgba(147,51,234,0.4) !important;
  -webkit-text-fill-color: #9333EA !important;
  -webkit-text-stroke: 0 !important;
  background: none !important;
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$cssContent = [IO.File]::ReadAllText($cssPath)
$cssContent += $cssAppend
[IO.File]::WriteAllText($cssPath, $cssContent)
