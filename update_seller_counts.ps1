$file = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"

if (Test-Path $file) {
    $content = [IO.File]::ReadAllText($file)
    
    $content = $content.Replace("const diesytCount = 1;", "const diesytCount = 7;")
    $content = $content.Replace("const krazyCount  = 3;", "const krazyCount  = 5;")
    
    [IO.File]::WriteAllText($file, $content)
}
