$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"

if (Test-Path $cssPath) {
    $content = [IO.File]::ReadAllText($cssPath)
    
    # Update the hidden class to override the flex !important
    $content = $content.Replace(".card.hidden {`r`n      display: none;`r`n    }", ".card.hidden {`r`n      display: none !important;`r`n    }")
    $content = $content.Replace(".card.hidden {`n      display: none;`n    }", ".card.hidden {`n      display: none !important;`n    }")

    # Fallback if the replace fails
    if ($content -notmatch "display: none !important;") {
        $content += "`n.card.hidden, .hidden { display: none !important; }`n"
    }

    [IO.File]::WriteAllText($cssPath, $content)
}
