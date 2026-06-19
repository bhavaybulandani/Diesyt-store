$stylePath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"

$appendCSS = @"

/* --- MONOCHROME OVERRIDE --- */
:root {
  --bg: #070610;
  --surface: #070610;
  --card-bg: transparent;
  --border: rgba(255,255,255,0.08);
  --nav-bg: #070610;
  --gold: #ffffff;
  --gold-light: #ffffff;
  --gold-dim: transparent;
  --text: #ffffff;
  --muted: rgba(255,255,255,0.4);
  --muted2: rgba(255,255,255,0.4);
}

* {
  box-shadow: none !important;
  text-shadow: none !important;
}

body, nav, header, section, footer, .card, .why-card, .vouch-card, .hero-section {
  background: #070610 !important;
  background-image: none !important;
}

body::before, body::after, .grid-lines, .hero-bg-glow, .hero-overlay, .card-glow, .card::before, .card::after, .hero-bracket-tr, .hero-bracket-bl, .hero-eyebrow, nav::after {
  display: none !important;
  background: none !important;
}

.text-red, .accent-word, .shine, .stat-num, .card-price, .why-title, .s-eye, .seller-name, .hero-h1, .s-title, .card-name {
  color: #ffffff !important;
  text-shadow: none !important;
  -webkit-text-fill-color: #ffffff !important;
}

p, span, div, .card-desc {
  color: rgba(255,255,255,0.4);
}

h1, h2, h3, h4, h5, h6, .hero-h1, .s-title, .card-name, .text-red, .accent-word, .shine, .stat-num, .card-price, .why-title, .s-eye, .seller-name {
  color: #ffffff !important;
}

.nav-btn, .btn-primary-red, .btn-gold, .btn-ghost, .card-buy, .seller-btn {
  background: #ffffff !important;
  color: #000000 !important;
  border: none !important;
  box-shadow: none !important;
  text-shadow: none !important;
}

.nav-btn:hover, .btn-primary-red:hover, .btn-gold:hover, .btn-ghost:hover, .card-buy:hover, .seller-btn:hover {
  background: #dddddd !important;
  color: #000000 !important;
}

.card, .why-card, .vouch-card, .hero-stats-box, .stat-box {
  background: transparent !important;
  border: 1px solid rgba(255,255,255,0.08) !important;
}

.card-tags .tag, .card-pill {
  background: transparent !important;
  border: 1px solid rgba(255,255,255,0.08) !important;
  color: rgba(255,255,255,0.4) !important;
}

/* Specific component overrides */
.nav-logo, .nav-logo::before {
  color: #ffffff !important;
  -webkit-text-fill-color: #ffffff !important;
  background: none !important;
  text-shadow: none !important;
  filter: none !important;
}

.theme-toggle {
  display: none !important;
}

/* Ensure images don't have borders */
img {
  border: none !important;
  box-shadow: none !important;
}

#cta {
    background: #070610 !important;
    border: none !important;
}

/* Overrides for dynamic elements */
.nav-logo {
  background-image: none !important;
}
"@

Add-Content -Path $stylePath -Value $appendCSS

# Process HTML Files
$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $html = [IO.File]::ReadAllText($file)
        
        # Replace inline styles for SOLD OUT / BOOKED
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)color:#C084FC;border:1px solid rgba\(147,51,234,0\.5\);background:rgba\(147,51,234,0\.1\)", "color:rgba(255,255,255,0.4);border:1px solid rgba(255,255,255,0.08);background:transparent;")
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)border:2px solid #[a-fA-F0-9]{3,6};padding:[^;`"`']*", "border:1px solid rgba(255,255,255,0.08);padding:0.4rem 1.2rem;")
        $html = [Text.RegularExpressions.Regex]::Replace($html, "(?i)color:#[a-fA-F0-9]{3,6};(border:)", "color:rgba(255,255,255,0.4);`$1")

        [IO.File]::WriteAllText($file, $html)
    }
}
