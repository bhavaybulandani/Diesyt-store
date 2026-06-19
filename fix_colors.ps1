$stylePath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$styleText = [IO.File]::ReadAllText($stylePath)

# 1. Colors Replacement
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#ff3b3b", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#ff5a5a", "#C084FC")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#cc0000", "#7c3aed")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#e60000", "#8b5cf6")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#f59e0b", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*255\s*,\s*59\s*,\s*59", "rgba(147, 51, 234")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*204\s*,\s*0\s*,\s*0", "rgba(109, 40, 217")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*200\s*,\s*40\s*,\s*40", "rgba(147, 51, 234")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*255\s*,\s*90\s*,\s*90", "rgba(147, 51, 234")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*255\s*,\s*70\s*,\s*85", "rgba(147, 51, 234")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*255\s*,\s*43\s*,\s*110", "rgba(147, 51, 234")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#FF4655", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#FF6B35", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#F43F5E", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#e74c3c", "#9333EA")
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)#f39c12", "#9333EA")

# Fix CTA Background tint if any
$styleText = [Text.RegularExpressions.Regex]::Replace($styleText, "(?i)rgba\(\s*255\s*,\s*0\s*,\s*0", "rgba(147, 51, 234")

$appendCSS = @"

/* URGENT FIXES */
header.hero-section {
    background: radial-gradient(ellipse at 70% 50%, rgba(147,51,234,0.12) 0%, transparent 60%), #070610 !important;
}

#cta {
    background: rgba(147,51,234,0.06) !important;
    border: 1px solid rgba(147,51,234,0.15) !important;
}

.card-tags .tag {
    background: rgba(147,51,234,0.08) !important;
    border: 1px solid rgba(147,51,234,0.2) !important;
    color: #C084FC !important;
    font-size: 11px !important;
    border-radius: 4px !important;
    padding: 3px 8px !important;
    text-transform: none !important;
    font-family: 'Inter', sans-serif !important;
}

.card-buy {
    background: linear-gradient(90deg, #9333EA, #C084FC) !important;
    color: #ffffff !important;
    width: 100% !important;
    text-align: center !important;
    padding: 10px 0 !important;
    border: none !important;
    border-radius: 6px !important;
    font-weight: 700 !important;
    display: inline-block !important;
    box-sizing: border-box !important;
}
"@

$styleText += $appendCSS
[IO.File]::WriteAllText($stylePath, $styleText)

# Process HTML Files
$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $html = [IO.File]::ReadAllText($file)
        
        # Change Buy on WhatsApp / BUY ON WA text
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)Buy on WhatsApp\b", "BUY ON WHATSAPP")
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)BUY ON WA( &#x2197;)?", "BUY ON WHATSAPP")
        
        # Fix stray tags like ]Perfect
        $html = [Text.RegularExpressions.Regex]::Replace($html, "\](Perfect|First)", '$1')
        
        # Replace inline styles for SOLD OUT / BOOKED
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)border:2px solid #[a-f0-9]{6};color:#[a-f0-9]{6};", "border: 1px solid rgba(147,51,234,0.5); color: #C084FC; background: rgba(147,51,234,0.1);")
        
        # Sometimes it's written as border:2px solid #e74c3c;padding...
        # Let's match the span inline style for the badges directly
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)color:#e74c3c;.*?border:2px solid #e74c3c", "color:#C084FC;border:1px solid rgba(147,51,234,0.5);background:rgba(147,51,234,0.1)")
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)color:#f39c12;.*?border:2px solid #f39c12", "color:#C084FC;border:1px solid rgba(147,51,234,0.5);background:rgba(147,51,234,0.1)")

        [IO.File]::WriteAllText($file, $html)
    }
}
