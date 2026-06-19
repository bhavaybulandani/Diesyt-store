$path = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$text = [IO.File]::ReadAllText($path)

$search = "body::after {`r`n  --card-bg: rgba(147, 51, 234, 0.05);"

$replace = @"
body::after {
  bottom: -20%;
  right: -10%;
  background: transparent 0%, transparent 70%);
}

#listings, .s-head {
  position: relative;
}

/* Side Glow removed */
section {
  box-shadow: none !important;
}

/* --- PREMIUM PURPLE OVERRIDES --- */
:root {
  --bg: #070610;
  --surface: #070610;
  --card-bg: rgba(147, 51, 234, 0.05);
"@

$text = $text.Replace($search, $replace)

# Fallback for unix line endings
$searchUnix = "body::after {`n  --card-bg: rgba(147, 51, 234, 0.05);"
$text = $text.Replace($searchUnix, $replace)

[IO.File]::WriteAllText($path, $text)
