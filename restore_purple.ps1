$stylePath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$styleText = [IO.File]::ReadAllText($stylePath)

$monochromeIndex = $styleText.IndexOf("/* --- MONOCHROME OVERRIDE --- */")
if ($monochromeIndex -gt -1) {
    $styleText = $styleText.Substring(0, $monochromeIndex)
    [IO.File]::WriteAllText($stylePath, $styleText)
}

$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $html = [IO.File]::ReadAllText($file)
        
        # Restore SOLD OUT / BOOKED badges
        $html = [Text.RegularExpressions.Regex]::Replace($html, '(?i)color:rgba\(255,255,255,0\.4\);border:1px solid rgba\(255,255,255,0\.08\);background:transparent;', 'color:#C084FC;border:1px solid rgba(147,51,234,0.5);background:rgba(147,51,234,0.1);')
        
        # Restore Buy on WhatsApp
        $html = [Text.RegularExpressions.Regex]::Replace($html, '(?i)BUY ON WHATSAPP', 'Buy on WhatsApp')
        
        # Restore CTA Banner in index.html
        $html = [Text.RegularExpressions.Regex]::Replace($html, '(?i)background:\s*transparent;\s*border:\s*1px solid rgba\(255,\s*255,\s*255,\s*0\.08\);\s*border-radius:\s*12px;\s*text-align:\s*center;', 'background: rgba(147, 51, 234, 0.06); border: 1px solid rgba(147, 51, 234, 0.15); border-radius: 12px; text-align: center;')

        [IO.File]::WriteAllText($file, $html)
    }
}
