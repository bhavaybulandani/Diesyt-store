$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

$soldOverlay = '<div class="status-overlay" style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;border-radius:8px;"><span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#C084FC;letter-spacing:0.15em;border:2px solid #C084FC;padding:0.4rem 1.2rem;background:rgba(147,51,234,0.15);">SOLD OUT</span></div>'
$bookedOverlay = '<div class="status-overlay" style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;border-radius:8px;"><span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#C084FC;letter-spacing:0.15em;border:2px solid #C084FC;padding:0.4rem 1.2rem;background:rgba(147,51,234,0.15);">BOOKED</span></div>'

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        
        # 1. Fix Image paths in views/accounts.html
        if ($file.EndsWith("accounts.html")) {
            $content = [regex]::Replace($content, 'src="assets/images/', 'src="../assets/images/')
        }

        # 2. Remove old badges or overlays
        $content = [regex]::Replace($content, '(?i)<div class="badge-sold-out".*?</div>', '')
        $content = [regex]::Replace($content, '(?i)<div class="badge-booked".*?</div>', '')
        $content = [regex]::Replace($content, '(?i)<div class="status-overlay".*?</div>', '')
        # Also remove the live site's red/orange overlays if any exist in the local code
        $content = [regex]::Replace($content, '(?i)<div style="position:absolute;inset:0;background:rgba\(0,0,0,0\.6\);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span[^>]*>SOLD OUT</span></div>', '')
        $content = [regex]::Replace($content, '(?i)<div style="position:absolute;inset:0;background:rgba\(0,0,0,0\.6\);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span[^>]*>BOOKED</span></div>', '')

        # 3. Add the new overlays right after <div class="card-body"> so it sits inside the .card
        # Wait, if we use (?is)(data-status="sold"[^>]*>.*?<div class="card-thumb">), we can inject it right after card-thumb (which means it's a child of .card).
        $content = [regex]::Replace($content, '(?is)(data-status="sold"[^>]*>.*?<div class="card-thumb">)', "`$1`n" + $soldOverlay)
        $content = [regex]::Replace($content, '(?is)(data-status="booked"[^>]*>.*?<div class="card-thumb">)', "`$1`n" + $bookedOverlay)

        [IO.File]::WriteAllText($file, $content)
    }
}

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
if (Test-Path $cssPath) {
    $cssContent = [IO.File]::ReadAllText($cssPath)

    # 4. Replace .filter-btn CSS
    # Let's find the FILTER BUTTONS section and replace it.
    $filterIndex = $cssContent.IndexOf("/* FILTER BUTTONS */")
    if ($filterIndex -ge 0) {
        $cssContent = $cssContent.Substring(0, $filterIndex)
    }
    
    $newFilterCss = @"
/* FILTER BUTTONS (Clean Pill Style) */
.filter-btn {
  background: transparent !important;
  color: var(--muted) !important;
  border: 1px solid rgba(255,255,255,0.1) !important;
  border-bottom: 1px solid rgba(255,255,255,0.1) !important;
  box-shadow: none !important;
  border-radius: 20px !important;
  padding: 6px 16px !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 14px !important;
  letter-spacing: 0.05em !important;
  transition: all 0.2s ease !important;
  transform: none !important;
}
.filter-btn:hover {
  background: rgba(147, 51, 234, 0.1) !important;
  border-color: rgba(147, 51, 234, 0.4) !important;
  color: #fff !important;
  transform: none !important;
}
.filter-btn.active {
  background: rgba(147, 51, 234, 0.2) !important;
  border-color: #9333EA !important;
  color: #fff !important;
  box-shadow: 0 0 10px rgba(147, 51, 234, 0.2) !important;
}
.card {
  position: relative !important;
}
"@
    $cssContent += "`n" + $newFilterCss
    [IO.File]::WriteAllText($cssPath, $cssContent)
}
