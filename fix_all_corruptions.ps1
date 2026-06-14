$files = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\accounts.html"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        $c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)

        # Fix the krazy account image
        $c = $c.Replace('src="krazy_acc1.jpg"', 'src="acc1.jpeg"')

        # Fix prices
        $c = $c.Replace('?3?00', '&#x20B9;3,700')
        $c = $c.Replace('?2,000', '&#x20B9;2,000')
        $c = $c.Replace('?5,000', '&#x20B9;5,000')
        $c = $c.Replace('?14,000', '&#x20B9;14,000')
        $c = $c.Replace('?9,000', '&#x20B9;9,000')
        $c = $c.Replace('?6,500', '&#x20B9;6,500')
        $c = $c.Replace('?8,000', '&#x20B9;8,000')

        # Fix card pills
        $c = $c.Replace('? Clean Pick', '&#x2728; Clean Pick')
        $c = $c.Replace('?? Smurf Pick', '&#x2728; Smurf Pick')
        $c = $c.Replace('?? Booked', '&#x1F525; Booked')
        $c = $c.Replace('? New', '&#x2728; New')
        $c = $c.Replace('? Sold Out', '&#10060; Sold Out')

        # Fix buttons
        $c = $c.Replace('BUY ON WA ?', 'BUY ON WA &#x2197;')
        $c = $c.Replace('Buy on WA ?', 'Buy on WA &#x2197;')
        $c = $c.Replace('WhatsApp ?', 'WhatsApp &#x2197;')

        # Fix text corruptions
        $c = $c.Replace('&udiowide', 'Audiowide')
        $c = $c.Replace('ital?wght', 'ital,wght')
        $c = $c.Replace('N&V', 'NAV')
        $c = $c.Replace('CT&', 'CTA')
        $c = $c.Replace('F&Q', 'FAQ')
        $c = $c.Replace('&LL', 'ALL')
        $c = $c.Replace('&ccounts', 'Accounts')
        $c = $c.Replace('V&LOR&NT', 'VALORANT')
        $c = $c.Replace('INDI&''S', 'INDIA''S')
        $c = $c.Replace('M&RKETPL&CE', 'MARKETPLACE')
        $c = $c.Replace('View &ll Arsenal', 'View All Arsenal')
        $c = $c.Replace('Whats&pp', 'WhatsApp')
        $c = $c.Replace('&s long as', 'As long as')
        $c = $c.Replace('&sia', 'Asia')
        $c = $c.Replace('&ll rights', 'All rights')

        # Fix stars
        $c = $c.Replace('? ? ? ? ?', '&#x2B50; &#x2B50; &#x2B50; &#x2B50; &#x2B50;')

        # Fix CSS inline styling commas that turned to ?
        $c = $c.Replace('rgba(179?36,255?0.05)', 'rgba(179,36,255,0.05)')
        $c = $c.Replace('rgba(179?36,255?0.2)', 'rgba(179,36,255,0.2)')
        $c = $c.Replace('rgba(37,211?02?0.45)', 'rgba(37,211,2,0.45)')

        [System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
    }
}
