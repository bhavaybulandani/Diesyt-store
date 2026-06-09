$ErrorActionPreference = "Stop"
$path = "$PSScriptRoot\accounts.html"
$html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

function Find-MatchingCloseDiv {
    param([string]$h, [int]$startIdx)
    $depth = 0; $i = $startIdx
    while ($i -lt $h.Length) {
        if ($i + 4 -le $h.Length -and $h.Substring($i, 4) -eq '<div') { $depth++ }
        elseif ($i + 6 -le $h.Length -and $h.Substring($i, 6) -eq '</div>') { $depth--; if ($depth -eq 0) { return $i + 6 } }
        $i++
    }
    return -1
}

$soldOutPill = '<div class="card-pill" style="background:linear-gradient(135deg,#e74c3c,#c0392b);color:#fff;">&#10060; Sold Out</div>'
$soldOutOverlay = '<div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'

# Get grid
$gridStart = $html.IndexOf('<div class="grid">')
$gridEnd = Find-MatchingCloseDiv $html $gridStart
$grid = $html.Substring($gridStart, $gridEnd - $gridStart)

# Get all card positions
$cardMatches = [regex]::Matches($grid, '<div class="card ')
$positions = @(); foreach ($m in $cardMatches) { $positions += $m.Index }

function Get-CardContent {
    param([string]$g, [int[]]$pos, [int]$idx)
    $s = $pos[$idx]
    if ($idx + 1 -lt $pos.Count) { $e = $pos[$idx + 1] } else { $e = $g.LastIndexOf('</div>') + 6 }
    return $g.Substring($s, $e - $s)
}

function Mark-CardSoldOut {
    param([string]$cardHTML)
    # Update data-status to "sold"
    $cardHTML = [regex]::Replace($cardHTML, 'data-status="[^"]*"', 'data-status="sold"')
    # Replace existing card-pill content (whatever badge it has) with sold out pill
    $cardHTML = [regex]::Replace($cardHTML, '<div class="card-pill"[^>]*>.*?</div>', $soldOutPill)
    # Remove any existing overlay first
    $cardHTML = [regex]::Replace($cardHTML, '<div style="position:absolute;inset:0;background:rgba\(0,0,0,0\.[0-9]+\);z-index:10.*?</div>', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    # Find where to insert overlay: right after the card-pill div
    $pillEnd = $cardHTML.IndexOf($soldOutPill) + $soldOutPill.Length
    $cardHTML = $cardHTML.Substring(0, $pillEnd) + "`n      " + $soldOutOverlay + $cardHTML.Substring($pillEnd)
    return $cardHTML
}

# Process cards 3 and 5 (indices 2 and 4)
$targetIndices = @(2, 4)

$newGrid = $grid
$offset = 0

foreach ($idx in $targetIndices) {
    # Recalculate positions after each modification
    $currentPositions = @()
    $currentMatches = [regex]::Matches($newGrid, '<div class="card ')
    foreach ($m in $currentMatches) { $currentPositions += $m.Index }
    
    $s = $currentPositions[$idx]
    if ($idx + 1 -lt $currentPositions.Count) { $e = $currentPositions[$idx + 1] } else { $e = $newGrid.LastIndexOf('</div>') + 6 }
    
    $cardHTML = $newGrid.Substring($s, $e - $s)
    $modifiedCard = Mark-CardSoldOut $cardHTML
    
    $newGrid = $newGrid.Substring(0, $s) + $modifiedCard + $newGrid.Substring($s + $cardHTML.Length)
    Write-Host "Marked card $($idx + 1) as SOLD OUT"
}

# Replace grid in full HTML
$newHTML = $html.Substring(0, $gridStart) + $newGrid + $html.Substring($gridEnd)

[System.IO.File]::WriteAllText($path, $newHTML, [System.Text.Encoding]::UTF8)
Write-Host "Done! File saved."
