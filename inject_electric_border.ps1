$sellersFile = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"

if (Test-Path $sellersFile) {
    $content = [IO.File]::ReadAllText($sellersFile)
    
    # Add CSS import
    if ($content -notmatch "electric-border.css") {
        $content = $content.Replace('<link rel="stylesheet" href="../app/css/style.css" />', "<link rel=`"stylesheet`" href=`"../app/css/style.css`" />`n  <link rel=`"stylesheet`" href=`"../app/css/electric-border.css`" />")
    }

    # Add JS import
    if ($content -notmatch "electric-border.js") {
        $content = $content.Replace('<script src="../app/js/script.js"></script>', "<script src=`"../app/js/script.js`"></script>`n<script src=`"../app/js/electric-border.js`"></script>")
    }

    # Add initialization script
    if ($content -notmatch "new ElectricBorder") {
        $initScript = @"

  // ── Initialize Electric Borders ──
  document.querySelectorAll('.seller-card').forEach(card => {
    let color = card.id === 'seller-diesyt' ? '#9333EA' : '#4b09ff';
    new ElectricBorder(card, {
      color: color,
      speed: 1.2,
      chaos: 0.15,
      borderRadius: 20
    });
  });
</script>
"@
        $content = $content.Replace("</script>`n</body>", $initScript + "`n</body>")
        $content = $content.Replace("</script>`r`n</body>", $initScript + "`r`n</body>")
    }

    [IO.File]::WriteAllText($sellersFile, $content)
}
