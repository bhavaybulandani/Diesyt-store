# add_booked.ps1 - Add the sold-out/booked accounts to the main page grid

$ErrorActionPreference = "Stop"

$indexPath = "$PSScriptRoot\index.html"
$vercelPath = "$PSScriptRoot\vercel_index.html"

$html = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$vercelHTML = [System.IO.File]::ReadAllText($vercelPath, [System.Text.Encoding]::UTF8)

# Function to find matching closing div
function Find-MatchingCloseDiv {
    param([string]$h, [int]$startIdx)
    $depth = 0
    $i = $startIdx
    while ($i -lt $h.Length) {
        if ($i + 4 -le $h.Length -and $h.Substring($i, 4) -eq '<div') {
            $depth++
        }
        elseif ($i + 6 -le $h.Length -and $h.Substring($i, 6) -eq '</div>') {
            $depth--
            if ($depth -eq 0) {
                return $i + 6
            }
        }
        $i++
    }
    return -1
}

# Extract vercel grid to find the sold-out cards
$vGridStart = $vercelHTML.IndexOf('<div class="grid">')
$vGridEnd = Find-MatchingCloseDiv $vercelHTML $vGridStart
$vGrid = $vercelHTML.Substring($vGridStart, $vGridEnd - $vGridStart)

# Find all card positions in vercel grid
$vCardPositions = @()
$sp = 0
while ($true) {
    $ci = $vGrid.IndexOf('<div class="card ', $sp)
    if ($ci -eq -1) { break }
    $vCardPositions += $ci
    $sp = $ci + 20
}
Write-Host "Vercel grid has $($vCardPositions.Count) cards"

# Extract individual cards from vercel grid
function Get-CardHTML {
    param([string]$gridHTML, [int[]]$positions, [int]$cardIndex)
    $start = $positions[$cardIndex]
    if ($cardIndex + 1 -lt $positions.Count) {
        $end = $positions[$cardIndex + 1]
    } else {
        # Last card - find the closing </div> of the grid
        $end = $gridHTML.LastIndexOf('</div>')
    }
    return $gridHTML.Substring($start, $end - $start)
}

# Find the cards containing "Reaver 2.0, Primordium" and "Kuronami, Narukami"
$soldCards = @()
$soldOutOverlay = '<div class="card-pill">&#10060; Sold Out</div><div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'

for ($i = 0; $i -lt $vCardPositions.Count; $i++) {
    $cardHTML = Get-CardHTML $vGrid $vCardPositions $i
    
    if ($cardHTML -match 'Reaver 2\.0.*Primordium.*Kuronami|Kuronami.*Narukami.*Champs') {
        # Extract the card name for logging
        $nameMatch = [regex]::Match($cardHTML, '<h3[^>]*>(.*?)</h3>')
        $name = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { "Unknown" }
        Write-Host "Found sold-out card $($i+1): $name"
        
        # Add sold-out overlay after the opening card div tag
        $tagEnd = $cardHTML.IndexOf('>')
        $cardTag = $cardHTML.Substring(0, $tagEnd + 1)
        
        # Update data-status to sold
        if ($cardTag -match 'data-status=') {
            $cardTag = $cardTag -replace 'data-status="[^"]*"', 'data-status="sold"'
        } else {
            $cardTag = $cardTag -replace 'class="card', 'data-status="sold" class="card'
        }
        
        $modifiedCard = $cardTag + "`n      " + $soldOutOverlay + $cardHTML.Substring($tagEnd + 1)
        $soldCards += $modifiedCard
    }
}

Write-Host "Found $($soldCards.Count) sold-out cards to add"

if ($soldCards.Count -eq 0) {
    Write-Host "ERROR: No sold-out cards found! Let's search more broadly..."
    # Debug: show card names
    for ($i = 0; $i -lt [Math]::Min(20, $vCardPositions.Count); $i++) {
        $cardHTML = Get-CardHTML $vGrid $vCardPositions $i
        $nameMatch = [regex]::Match($cardHTML, '<h3[^>]*>(.*?)</h3>')
        $name = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { "Unknown" }
        $hasReaver = $cardHTML.Contains('Reaver')
        $hasKuronami = $cardHTML.Contains('Kuronami')
        Write-Host "  Card $($i+1): $name (Reaver=$hasReaver, Kuronami=$hasKuronami)"
    }
    exit 1
}

# Now add these sold cards to the index.html grid
$gridStart = $html.IndexOf('<div class="grid">')
$gridEnd = Find-MatchingCloseDiv $html $gridStart
$currentGrid = $html.Substring($gridStart, $gridEnd - $gridStart)

# Insert sold cards before the closing </div> of the grid
$closingDivPos = $currentGrid.LastIndexOf('</div>')
$newGrid = $currentGrid.Substring(0, $closingDivPos) + "`n    " + ($soldCards -join "`n    ") + "`n</div>"

$html = $html.Substring(0, $gridStart) + $newGrid + $html.Substring($gridEnd)

# Verify
$finalCardCount = ([regex]::Matches($html, '<div class="card ')).Count
Write-Host ""
Write-Host "=== DONE ==="
Write-Host "Final card count on main page: $finalCardCount"

[System.IO.File]::WriteAllText($indexPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "File saved: $($html.Length) chars"
