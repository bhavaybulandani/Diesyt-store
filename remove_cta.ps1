$indexFile = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html"

if (Test-Path $indexFile) {
    $content = [IO.File]::ReadAllText($indexFile)
    
    # Remove the entire <section id="cta"> block
    $content = [regex]::Replace($content, '(?is)<!-- CTA -->\s*<section id="cta".*?</section>', '')
    
    [IO.File]::WriteAllText($indexFile, $content)
}
