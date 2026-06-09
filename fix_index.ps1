# fix_index.ps1 - Limit grid to 2 cards, fix vouch section from vercel reference

$ErrorActionPreference = "Stop"

$indexPath = "$PSScriptRoot\index.html"
$vercelPath = "$PSScriptRoot\vercel_index.html"

$html = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$vercelHTML = [System.IO.File]::ReadAllText($vercelPath, [System.Text.Encoding]::UTF8)

Write-Host "Index HTML length: $($html.Length)"

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

# ============================================================
# STEP 1: Trim grid to only first 2 cards
# ============================================================
$gridStart = $html.IndexOf('<div class="grid">')
if ($gridStart -eq -1) {
    Write-Host "ERROR: Grid not found"
    exit 1
}

$gridEnd = Find-MatchingCloseDiv $html $gridStart
$grid = $html.Substring($gridStart, $gridEnd - $gridStart)

Write-Host "Current grid length: $($grid.Length)"
$totalCards = ([regex]::Matches($grid, '<div class="card ')).Count
Write-Host "Total cards in grid: $totalCards"

# Find all card positions within the grid
$cardPositions = @()
$searchPos = 0
while ($true) {
    $cardIdx = $grid.IndexOf('<div class="card ', $searchPos)
    if ($cardIdx -eq -1) { break }
    $cardPositions += $cardIdx
    $searchPos = $cardIdx + 20
}

Write-Host "Found $($cardPositions.Count) card positions"

if ($cardPositions.Count -ge 3) {
    # Keep only first 2 cards - cut at the start of the 3rd card
    $cutPoint = $cardPositions[2]
    $newGrid = '<div class="grid">' + "`n" + $grid.Substring($grid.IndexOf('>') + 1, $cutPoint - ($grid.IndexOf('>') + 1)) + "`n</div>"
    Write-Host "New grid length: $($newGrid.Length)"
    
    $newCardCount = ([regex]::Matches($newGrid, '<div class="card ')).Count
    Write-Host "Cards in new grid: $newCardCount"
    
    # Replace grid in HTML
    $html = $html.Substring(0, $gridStart) + $newGrid + $html.Substring($gridEnd)
    Write-Host "Grid trimmed to 2 cards"
} else {
    Write-Host "Grid already has 2 or fewer cards, no trimming needed"
}

# ============================================================
# STEP 2: Replace vouch section with vercel's vouch section
# ============================================================
$localVouchStart = $html.IndexOf('<section id="vouches">')
$vercelVouchStart = $vercelHTML.IndexOf('<section id="vouches">')

if ($localVouchStart -gt -1 -and $vercelVouchStart -gt -1) {
    $localVouchEnd = $html.IndexOf('</section>', $localVouchStart) + 10
    $vercelVouchEnd = $vercelHTML.IndexOf('</section>', $vercelVouchStart) + 10
    
    $vercelVouchSection = $vercelHTML.Substring($vercelVouchStart, $vercelVouchEnd - $vercelVouchStart)
    
    Write-Host "Vercel vouch section: $($vercelVouchSection.Length) chars"
    $vercelVouchImgs = ([regex]::Matches($vercelVouchSection, '<img')).Count
    Write-Host "Vercel vouch images: $vercelVouchImgs"
    
    $html = $html.Substring(0, $localVouchStart) + $vercelVouchSection + $html.Substring($localVouchEnd)
    Write-Host "Vouch section replaced with vercel's version"
} else {
    Write-Host "WARNING: Could not find vouch section in one or both files"
    Write-Host "Local: $localVouchStart, Vercel: $vercelVouchStart"
}

# ============================================================
# STEP 3: Write output
# ============================================================
[System.IO.File]::WriteAllText($indexPath, $html, [System.Text.Encoding]::UTF8)

$finalCardCount = ([regex]::Matches($html, '<div class="card ')).Count
$finalVouchCards = ([regex]::Matches($html, 'vouch-card')).Count
Write-Host ""
Write-Host "=== DONE ==="
Write-Host "Final file size: $($html.Length) chars"
Write-Host "Final card count: $finalCardCount"
Write-Host "Final vouch cards: $finalVouchCards"
