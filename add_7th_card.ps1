$ErrorActionPreference = "Stop"

$indexPath = "$PSScriptRoot\index.html"
$accountsPath = "$PSScriptRoot\accounts.html"

$indexHTML = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$accountsHTML = [System.IO.File]::ReadAllText($accountsPath, [System.Text.Encoding]::UTF8)

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

# --- 1. Extract grid from accounts.html ---
$accGridStart = $accountsHTML.IndexOf('<div class="grid">')
$accGridEnd = Find-MatchingCloseDiv $accountsHTML $accGridStart
$accGrid = $accountsHTML.Substring($accGridStart, $accGridEnd - $accGridStart)

# Find all card positions in accounts grid
$accCardPositions = @()
$sp = 0
while ($true) {
    $ci = $accGrid.IndexOf('<div class="card ', $sp)
    if ($ci -eq -1) { break }
    $accCardPositions += $ci
    $sp = $ci + 20
}
Write-Host "Accounts grid has $($accCardPositions.Count) cards"

# Extract the 7th card (index 6)
if ($accCardPositions.Count -lt 7) {
    Write-Host "ERROR: Less than 7 cards found in accounts.html"
    exit 1
}

$start7 = $accCardPositions[6]
if (7 -lt $accCardPositions.Count) {
    $end7 = $accCardPositions[7]
} else {
    $end7 = $accGrid.LastIndexOf('</div>')
}
$card7HTML = $accGrid.Substring($start7, $end7 - $start7)
Write-Host "Extracted 7th card: $($card7HTML.Substring(0, 100))..."

# --- 2. Add card to index.html grid ---
$indexGridStart = $indexHTML.IndexOf('<div class="grid">')
$indexGridEnd = Find-MatchingCloseDiv $indexHTML $indexGridStart
$indexGrid = $indexHTML.Substring($indexGridStart, $indexGridEnd - $indexGridStart)

# Insert the 7th card before the closing </div> of the grid
$closingDivPos = $indexGrid.LastIndexOf('</div>')
$newIndexGrid = $indexGrid.Substring(0, $closingDivPos) + "`n    " + $card7HTML + "`n" + $indexGrid.Substring($closingDivPos)

$indexHTML = $indexHTML.Substring(0, $indexGridStart) + $newIndexGrid + $indexHTML.Substring($indexGridEnd)

# Verify
$finalCardCount = ([regex]::Matches($indexHTML, '<div class="card ')).Count
Write-Host "Final card count on main page: $finalCardCount"

[System.IO.File]::WriteAllText($indexPath, $indexHTML, [System.Text.Encoding]::UTF8)
Write-Host "Done!"
