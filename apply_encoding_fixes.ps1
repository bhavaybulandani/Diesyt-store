$htmlFiles = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)

$newTicker = @"
<div class="ticker-content">
    <span>&#x26A1; 50+ ACCOUNTS SOLD <span class="ticker-dot">&#x25C6;</span> &#x1F6E1;&#xFE0F; 100% VERIFIED <span class="ticker-dot">&#x25C6;</span> &#x23F1;&#xFE0F; DELIVERY IN MINUTES <span class="ticker-dot">&#x25C6;</span> &#x1F6AB; NO BANS EVER <span class="ticker-dot">&#x25C6;</span> &#x1F4AC; TRUSTED BY COMMUNITY <span class="ticker-dot">&#x25C6;</span> </span>
    <span>&#x26A1; 50+ ACCOUNTS SOLD <span class="ticker-dot">&#x25C6;</span> &#x1F6E1;&#xFE0F; 100% VERIFIED <span class="ticker-dot">&#x25C6;</span> &#x23F1;&#xFE0F; DELIVERY IN MINUTES <span class="ticker-dot">&#x25C6;</span> &#x1F6AB; NO BANS EVER <span class="ticker-dot">&#x25C6;</span> &#x1F4AC; TRUSTED BY COMMUNITY <span class="ticker-dot">&#x25C6;</span> </span>
  </div>
"@

$newBadges = @"
<div class="trust-badges-row">
      <span>&#x2713; SSL Secured</span> <span>&middot;</span> <span>&#x2713; 100% Verified</span> <span>&middot;</span> <span>&#x2713; Instant Delivery</span> <span>&middot;</span> <span>&#x2713; No Bans</span>
    </div>
"@

foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)

        # Fix garbled ticker
        $content = [regex]::Replace($content, '(?is)<div class="ticker-content">.*?</div>', $newTicker)

        # Fix garbled badges
        $content = [regex]::Replace($content, '(?is)<div class="trust-badges-row">.*?</div>', $newBadges)

        # Fix garbled Why Choose Us icons (only on index)
        $content = [regex]::Replace($content, '(?is)<div class="why-icon-circle">[^<]*?</div>\s*<div class="why-title-new">Instant Delivery</div>', '<div class="why-icon-circle">&#x26A1;</div><div class="why-title-new">Instant Delivery</div>')
        $content = [regex]::Replace($content, '(?is)<div class="why-icon-circle">[^<]*?</div>\s*<div class="why-title-new">100% Safe</div>', '<div class="why-icon-circle">&#x1F512;</div><div class="why-title-new">100% Safe</div>')
        $content = [regex]::Replace($content, '(?is)<div class="why-icon-circle">[^<]*?</div>\s*<div class="why-title-new">Best Prices</div>', '<div class="why-icon-circle">&#x1F4B0;</div><div class="why-title-new">Best Prices</div>')
        $content = [regex]::Replace($content, '(?is)<div class="why-icon-circle">[^<]*?</div>\s*<div class="why-title-new">Trusted Seller</div>', '<div class="why-icon-circle">&#x1F3C6;</div><div class="why-title-new">Trusted Seller</div>')

        # Fix whatsapp SVG A path
        $content = $content.Replace("&11.93", "A11.93").Replace("&9.862", "A9.862")

        [IO.File]::WriteAllText($file, $content)
    }
}
