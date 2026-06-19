$file = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"

if (Test-Path $file) {
    $content = [IO.File]::ReadAllText($file)
    
    $oldScript = @"
    new ElectricBorder(card, {
      color: color,
      speed: 1.2,
      chaos: 0.15,
      borderRadius: 20
    });
"@
    $newScript = @"
    new ElectricBorder(card, {
      color: color,
      speed: 1.4,
      chaos: 0.45,
      thickness: 2,
      borderRadius: 20
    });
"@
    
    # We will just replace it with Regex to be safe
    $content = [regex]::Replace($content, '(?s)new ElectricBorder\(card, \{.*?\}\);', $newScript)

    [IO.File]::WriteAllText($file, $content)
}
