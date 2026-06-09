$accounts = Get-Content accounts.html
$newAccounts = $accounts[0..30] + '<header style="padding: 100px 0 50px; text-align: center;"><h1 class="hero-h1" style="font-size: 3rem;">Premium <span class="shine">Arsenal</span></h1></header>' + $accounts[81..($accounts.Length-1)]
$newAccounts | Set-Content accounts.html

$index = Get-Content index.html
$newIndexHero = @(
'<!-- HERO -->',
'<header style="position: relative; overflow: hidden; padding: 120px 0 80px; text-align: center;">',
'  <!-- Placeholder Video Background -->',
'  <video class="hero-video" autoplay loop muted playsinline style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; z-index: -1; opacity: 0.4;">',
'    <!-- Replace src with the user''s video URL when ready -->',
'    <source src="" type="video/mp4">',
'  </video>',
'  <span class="hero-badge">India''s #1 Valorant Marketplace</span>',
'  <h1 class="hero-h1">',
'    Elevate Your<br>',
'    <span class="shine">Game</span>',
'  </h1>',
'  <p class="hero-sub">',
'    Handpicked accounts with the rarest skins. Trusted delivery, full access, instant transaction — every single time.',
'  </p>',
'  <div class="hero-btns">',
'    <a href="accounts.html" class="btn-gold">Browse Accounts</a>',
'    <a href="https://chat.whatsapp.com/DoKjFZVwBpB0WTpKS8KIkM?mode=gi_t" class="btn-ghost">View All Vouches</a>',
'  </div>',
'</header>'
)

$newIndex = $index[0..30] + $newIndexHero + $index[81..($index.Length-1)]
$newIndex | Set-Content index.html
