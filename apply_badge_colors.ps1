$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        
        # Replace SOLD OUT purple colors with red (#e74c3c)
        $content = [regex]::Replace($content, '(?i)<span style="font-family:''Bebas Neue'',sans-serif;font-size:1\.1rem;font-weight:700;color:#C084FC;letter-spacing:0\.15em;border:2px solid #C084FC;padding:0\.4rem 1\.2rem;background:rgba\(147,51,234,0\.15\);">SOLD OUT</span>', '<span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;background:rgba(231,76,60,0.15);">SOLD OUT</span>')
        
        # Replace BOOKED purple colors with yellow-orange (#f39c12)
        $content = [regex]::Replace($content, '(?i)<span style="font-family:''Bebas Neue'',sans-serif;font-size:1\.1rem;font-weight:700;color:#C084FC;letter-spacing:0\.15em;border:2px solid #C084FC;padding:0\.4rem 1\.2rem;background:rgba\(147,51,234,0\.15\);">BOOKED</span>', '<span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#f39c12;letter-spacing:0.15em;border:2px solid #f39c12;padding:0.4rem 1.2rem;background:rgba(243,156,18,0.15);">BOOKED</span>')

        [IO.File]::WriteAllText($file, $content)
    }
}
