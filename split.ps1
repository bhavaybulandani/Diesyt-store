$html = Invoke-WebRequest -Uri "https://diesyt-store.vercel.app/" -UseBasicParsing | Select-Object -ExpandProperty Content

$cssMatches = [regex]::Matches($html, '(?si)<style[^>]*>(.*?)</style>')
$cssContent = ""
foreach ($match in $cssMatches) {
    $cssContent += $match.Groups[1].Value + "`n"
}
$cssContent | Out-File "style.css" -Encoding utf8

$jsMatches = [regex]::Matches($html, '(?si)<script[^>]*>(.*?)</script>')
$jsContent = ""
foreach ($match in $jsMatches) {
    $jsContent += $match.Groups[1].Value + "`n"
}
$jsContent | Out-File "script.js" -Encoding utf8

$newHtml = $html -replace '(?si)<style[^>]*>.*?</style>', ''
$newHtml = $newHtml -replace '(?si)<script[^>]*>.*?</script>', ''

$newHtml = $newHtml -replace '(?si)(</head>)', "<link rel=`"stylesheet`" href=`"style.css`" />`n`$1"
$newHtml = $newHtml -replace '(?si)(</body>)', "<script src=`"script.js`"></script>`n`$1"

$newHtml | Out-File "index.html" -Encoding utf8
