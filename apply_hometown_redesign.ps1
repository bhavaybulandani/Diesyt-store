$cssAppend = @"

/* --- UI FIXES BATCH 6: HOMETOWN STRUCTURAL REDESIGN --- */

/* 1. TICKER BAR */
.ticker-bar {
  background: rgba(147,51,234,0.08) !important;
  border-top: 1px solid rgba(147,51,234,0.15) !important;
  border-bottom: 1px solid rgba(147,51,234,0.15) !important;
  padding: 10px 0 !important;
  overflow: hidden !important;
  display: flex !important;
  white-space: nowrap !important;
  position: relative !important;
  z-index: 10 !important;
}
.ticker-content {
  display: flex !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 13px !important; /* Slightly increased for readability from 11px */
  font-weight: 600 !important;
  letter-spacing: 0.1em !important;
  color: rgba(255,255,255,0.5) !important;
  animation: scrollTicker 30s linear infinite !important;
}
.ticker-content span {
  padding-right: 3rem !important;
}
.ticker-dot {
  color: #9333EA !important;
  margin: 0 1rem !important;
}
@keyframes scrollTicker {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* 2. WHY CHOOSE US (4-COLUMN) */
.why-grid-4 {
  display: grid !important;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)) !important;
  gap: 2rem !important;
  max-width: 1200px !important;
  margin: 3rem auto 0 !important;
  text-align: center !important;
}
.why-card-new {
  display: flex !important;
  flex-direction: column !important;
  align-items: center !important;
  background: transparent !important;
  padding: 1rem !important;
}
.why-icon-circle {
  width: 50px !important;
  height: 50px !important;
  border-radius: 50% !important;
  background: rgba(147,51,234,0.1) !important;
  border: 1px solid rgba(147,51,234,0.2) !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  font-size: 20px !important;
  margin-bottom: 1.2rem !important;
  box-shadow: 0 0 15px rgba(147,51,234,0.15) !important;
}
.why-title-new {
  color: #fff !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-weight: 700 !important;
  font-size: 18px !important;
  letter-spacing: 0.05em !important;
  text-transform: uppercase !important;
  margin-bottom: 0.5rem !important;
}
.why-desc-new {
  color: rgba(255,255,255,0.4) !important;
  font-size: 13px !important;
  line-height: 1.5 !important;
}

/* 3. FINAL CTA BANNER */
.cta-banner {
  background: rgba(147,51,234,0.06) !important;
  border: 1px solid rgba(147,51,234,0.15) !important;
  border-radius: 12px !important;
  padding: 60px 40px !important;
  text-align: center !important;
  max-width: 1100px !important;
  margin: 0 auto !important;
  box-shadow: 0 10px 40px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.05) !important;
}
.cta-title-new {
  font-family: 'Bebas Neue', sans-serif !important;
  font-size: 3.5rem !important;
  color: #fff !important;
  text-shadow: 0 0 20px rgba(147,51,234,0.5) !important;
  margin-bottom: 1rem !important;
  letter-spacing: 0.05em !important;
}
.cta-sub-new {
  color: rgba(255,255,255,0.4) !important;
  font-size: 1.1rem !important;
  margin-bottom: 2.5rem !important;
}
.cta-buttons {
  display: flex !important;
  gap: 1rem !important;
  justify-content: center !important;
  margin-bottom: 2.5rem !important;
  flex-wrap: wrap !important;
}
.trust-badges-row {
  display: flex !important;
  justify-content: center !important;
  gap: 1.5rem !important;
  font-size: 12px !important;
  color: rgba(255,255,255,0.3) !important;
  text-transform: uppercase !important;
  letter-spacing: 0.1em !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-weight: 600 !important;
  flex-wrap: wrap !important;
}
.trust-badges-row span {
  display: inline-block !important;
}

/* 4. FOOTER UPGRADE */
.footer-new {
  border-top: 1px solid rgba(147,51,234,0.12) !important;
  background: #070610 !important;
  padding: 2rem 7% !important;
  display: grid !important;
  grid-template-columns: 1fr auto 1fr !important;
  align-items: center !important;
  gap: 2rem !important;
}
.foot-left {
  display: flex !important;
  flex-direction: column !important;
  gap: 0.3rem !important;
}
.foot-logo-new {
  font-family: 'Audiowide', sans-serif !important;
  font-size: 1.2rem !important;
  color: #fff !important;
  letter-spacing: 0.1em !important;
}
.foot-tagline {
  color: rgba(255,255,255,0.3) !important;
  font-size: 12px !important;
}
.foot-center {
  display: flex !important;
  gap: 2rem !important;
}
.foot-center a {
  color: rgba(255,255,255,0.3) !important;
  font-size: 12px !important;
  text-transform: uppercase !important;
  text-decoration: none !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-weight: 600 !important;
  letter-spacing: 0.1em !important;
  transition: color 0.2s !important;
}
.foot-center a:hover {
  color: #9333EA !important;
}
.foot-right {
  text-align: right !important;
  color: rgba(255,255,255,0.3) !important;
  font-size: 12px !important;
}

@media (max-width: 768px) {
  .footer-new {
    grid-template-columns: 1fr !important;
    text-align: center !important;
    gap: 1.5rem !important;
  }
  .foot-right {
    text-align: center !important;
  }
  .foot-center {
    justify-content: center !important;
  }
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
if (Test-Path $cssPath) {
    $cssContent = [IO.File]::ReadAllText($cssPath)
    $cssContent += "`n" + $cssAppend
    [IO.File]::WriteAllText($cssPath, $cssContent)
}

# --- HTML INJECTIONS --- #
$indexFile = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html"
if (Test-Path $indexFile) {
    $indexContent = [IO.File]::ReadAllText($indexFile)

    # 1. Ticker
    $tickerHtml = @"
<div class="ticker-bar">
  <div class="ticker-content">
    <span>⚡ 50+ ACCOUNTS SOLD <span class="ticker-dot">◆</span> 🛡️ 100% VERIFIED <span class="ticker-dot">◆</span> ⏱️ DELIVERY IN MINUTES <span class="ticker-dot">◆</span> 🚫 NO BANS EVER <span class="ticker-dot">◆</span> 💬 TRUSTED BY COMMUNITY <span class="ticker-dot">◆</span> </span>
    <span>⚡ 50+ ACCOUNTS SOLD <span class="ticker-dot">◆</span> 🛡️ 100% VERIFIED <span class="ticker-dot">◆</span> ⏱️ DELIVERY IN MINUTES <span class="ticker-dot">◆</span> 🚫 NO BANS EVER <span class="ticker-dot">◆</span> 💬 TRUSTED BY COMMUNITY <span class="ticker-dot">◆</span> </span>
  </div>
</div>
"@
    # Insert right after </header>
    $indexContent = [regex]::Replace($indexContent, '(?i)(</header>)', "`$1`n" + $tickerHtml)

    # 2. Why Choose Us
    $whyHtml = @"
<!-- WHY -->
<section id="why" style="padding: 5rem 7%; text-align: center;">
  <div class="s-head reveal">
    <h2 class="s-title" style="color: #fff; font-size: 2.5rem; letter-spacing: 0.05em; font-family: 'Bebas Neue', sans-serif;">WHY CHOOSE US? <br><span class="shine" style="text-shadow: 0 0 20px rgba(147,51,234,0.5);">DIESYT STORE</span></h2>
  </div>
  <div class="why-grid-4">
    <div class="why-card-new reveal">
      <div class="why-icon-circle">⚡</div>
      <div class="why-title-new">Instant Delivery</div>
      <p class="why-desc-new">Accounts delivered within minutes of payment</p>
    </div>
    <div class="why-card-new reveal" style="transition-delay:0.1s">
      <div class="why-icon-circle">🔒</div>
      <div class="why-title-new">100% Safe</div>
      <p class="why-desc-new">Verified accounts, no bans, no cheats</p>
    </div>
    <div class="why-card-new reveal" style="transition-delay:0.2s">
      <div class="why-icon-circle">💰</div>
      <div class="why-title-new">Best Prices</div>
      <p class="why-desc-new">Lowest prices for premium Valorant accounts in India</p>
    </div>
    <div class="why-card-new reveal" style="transition-delay:0.3s">
      <div class="why-icon-circle">🏆</div>
      <div class="why-title-new">Trusted Seller</div>
      <p class="why-desc-new">50+ happy customers, all vouches verifiable</p>
    </div>
  </div>
</section>
"@
    # Replace existing <section id="why">...
    $indexContent = [regex]::Replace($indexContent, '(?is)<section id="why">.*?</section>', $whyHtml)

    # 3. CTA Banner
    $ctaHtml = @"
<!-- CTA -->
<section id="cta" class="reveal" style="padding: 2rem 7% 4rem;">
  <div class="cta-banner">
    <h2 class="cta-title-new">DON'T OVERPAY FOR SKINS.</h2>
    <p class="cta-sub-new">Get the premium inventory you deserve at unbeatable prices.</p>
    <div class="cta-buttons">
      <a href="views/accounts.html" class="btn-arsenal">BROWSE ACCOUNTS</a>
      <a href="https://wa.me/919999220415" class="btn-ghost">CONTACT US</a>
    </div>
    <div class="trust-badges-row">
      <span>✓ SSL Secured</span> <span>·</span> <span>✓ 100% Verified</span> <span>·</span> <span>✓ Instant Delivery</span> <span>·</span> <span>✓ No Bans</span>
    </div>
  </div>
</section>
"@
    # Replace existing <section id="cta">...
    $indexContent = [regex]::Replace($indexContent, '(?is)<section id="cta">.*?</section>', $ctaHtml)

    [IO.File]::WriteAllText($indexFile, $indexContent)
}

# 4. Footer everywhere
$footerHtml = @"
<!-- FOOTER -->
<footer class="footer-new">
  <div class="foot-left">
    <div class="foot-logo-new">DIESYT STORE</div>
    <div class="foot-tagline">India's #1 Valorant Store</div>
  </div>
  <div class="foot-center">
    <a href="index.html">HOME</a>
    <a href="views/sellers.html">SELLERS</a>
    <a href="views/accounts.html">ACCOUNTS</a>
  </div>
  <div class="foot-right">
    © 2026 Diesyt Store — All rights reserved.
  </div>
</footer>
"@
$footerHtmlRoot = @"
<!-- FOOTER -->
<footer class="footer-new">
  <div class="foot-left">
    <div class="foot-logo-new">DIESYT STORE</div>
    <div class="foot-tagline">India's #1 Valorant Store</div>
  </div>
  <div class="foot-center">
    <a href="index.html">HOME</a>
    <a href="sellers.html">SELLERS</a>
    <a href="accounts.html">ACCOUNTS</a>
  </div>
  <div class="foot-right">
    © 2026 Diesyt Store — All rights reserved.
  </div>
</footer>
"@

# Update Index
if (Test-Path $indexFile) {
    $indexContent = [IO.File]::ReadAllText($indexFile)
    $indexContent = [regex]::Replace($indexContent, '(?is)<footer>.*?</footer>', $footerHtml)
    [IO.File]::WriteAllText($indexFile, $indexContent)
}

# Update Subpages (accounts, sellers)
$subPages = @(
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\accounts.html",
    "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\views\sellers.html"
)
foreach ($file in $subPages) {
    if (Test-Path $file) {
        $content = [IO.File]::ReadAllText($file)
        $content = [regex]::Replace($content, '(?is)<footer>.*?</footer>', $footerHtmlRoot)
        
        # Also need to fix links inside the subpage footer so they go up a dir
        $content = [regex]::Replace($content, '"index.html"', '"../index.html"')
        $content = [regex]::Replace($content, '"sellers.html"', '"sellers.html"')
        $content = [regex]::Replace($content, '"accounts.html"', '"accounts.html"')

        [IO.File]::WriteAllText($file, $content)
    }
}
