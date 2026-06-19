$path = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$text = [IO.File]::ReadAllText($path)

$search = "h1, h2, h3, h4, h5, h6, .hero-h1, .s-title, .card-name {`r`n`r`n.nav-btn {"

$replace = @"
h1, h2, h3, h4, h5, h6, .hero-h1, .s-title, .card-name {
  font-family: 'Barlow Condensed', sans-serif !important;
  font-weight: 900 !important;
  text-transform: uppercase !important;
}

.accent-word {
  color: #9333EA !important;
  text-shadow: 0 0 18px rgba(147,51,234,0.4), 0 0 36px rgba(147,51,234,0.15) !important;
  -webkit-text-fill-color: #9333EA !important;
  background: none !important;
}

nav {
  background: rgba(7,6,15,0.98) !important;
  border-bottom: 1px solid rgba(147,51,234,0.12) !important;
}

nav::after {
  content: '';
  position: absolute;
  bottom: 0; left: 0; right: 0; height: 1px;
  background: linear-gradient(90deg, transparent, rgba(147,51,234,0.4), transparent) !important;
}

.nav-btn {
"@

$text = $text.Replace($search, $replace)

# Also check for Unix newlines just in case
$searchUnix = "h1, h2, h3, h4, h5, h6, .hero-h1, .s-title, .card-name {`n`n.nav-btn {"
$text = $text.Replace($searchUnix, $replace)

[IO.File]::WriteAllText($path, $text)
