$index = Get-Content index.html
$banner = @(
'  <!-- BOTTOM CTA -->',
'  <div style="margin-top: 4rem; padding: 3rem 2rem; background: rgba(179,136,255,0.05); border: 1px solid rgba(179,136,255,0.2); border-radius: 12px; text-align: center;" class="reveal">',
'    <h3 style="font-size: 2rem; font-family: ''Rajdhani'', sans-serif; color: #fff; margin-bottom: 1rem;">Ready for <span class="shine">Radiant</span>?</h3>',
'    <p style="color: var(--muted); margin-bottom: 2rem; max-width: 600px; margin-left: auto; margin-right: auto;">Browse our full collection of premium and high-tier Valorant accounts. Find your perfect match and dominate the leaderboard today.</p>',
'    <a href="accounts.html" class="btn-gold" style="display: inline-block;">View All Arsenal</a>',
'  </div>'
)

# Filter out lines 62-74 (filter bar) and lines 159-294 (extra cards)
$newIndex = @()
for ($i = 0; $i -lt $index.Length; $i++) {
    if ($i -ge 61 -and $i -le 73) { continue } # lines 62-74 (0-indexed: 61-73)
    if ($i -ge 158 -and $i -le 293) { continue } # lines 159-294 (0-indexed: 158-293)
    
    $newIndex += $index[$i]
    
    # After the grid closes (which was at line 295, now 294 because of indices, wait let's just match the closing div of grid)
    # Actually, it's safer to just inject it before the closing </section>
}

# The easiest way to inject is to find where </section> for listings is.
# We know it was at line 296. After deleting 13 lines (filter) and 136 lines (cards), it will be shifted.
# Let's just do it cleanly by searching for it.
$finalIndex = @()
$inListings = $false
for ($i = 0; $i -lt $newIndex.Length; $i++) {
    if ($newIndex[$i] -match 'id="listings"') { $inListings = $true }
    if ($inListings -and $newIndex[$i] -match '</section>') {
        $finalIndex += $banner
        $inListings = $false
    }
    $finalIndex += $newIndex[$i]
}

$finalIndex | Set-Content index.html
