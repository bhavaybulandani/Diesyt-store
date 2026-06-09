# fix_cards.ps1 - Extract grid and vouch sections from vercel_index.html and replace in index.html

$ErrorActionPreference = "Stop"

# Read files
$vercelHTML = [System.IO.File]::ReadAllText("$PSScriptRoot\vercel_index.html", [System.Text.Encoding]::UTF8)
$localHTML = [System.IO.File]::ReadAllText("$PSScriptRoot\index.html", [System.Text.Encoding]::UTF8)

Write-Host "Vercel HTML length: $($vercelHTML.Length)"
Write-Host "Local HTML length: $($localHTML.Length)"

# Function to find matching closing div
function Find-MatchingCloseDiv {
    param([string]$html, [int]$startIdx)
    $depth = 0
    $i = $startIdx
    while ($i -lt $html.Length) {
        if ($i + 4 -le $html.Length -and $html.Substring($i, 4) -eq '<div') {
            $depth++
        }
        elseif ($i + 6 -le $html.Length -and $html.Substring($i, 6) -eq '</div>') {
            $depth--
            if ($depth -eq 0) {
                return $i + 6
            }
        }
        $i++
    }
    return -1
}

# --- 1. Extract grid from vercel ---
$vercelGridStart = $vercelHTML.IndexOf('<div class="grid">')
if ($vercelGridStart -eq -1) {
    Write-Host "ERROR: Could not find grid in vercel. Trying alternate..."
    $cardIdx = $vercelHTML.IndexOf('class="card')
    if ($cardIdx -gt -1) {
        $ctx = $vercelHTML.Substring([Math]::Max(0, $cardIdx - 300), [Math]::Min(350, $vercelHTML.Length - [Math]::Max(0, $cardIdx - 300)))
        Write-Host "Context around first card: $ctx"
    }
    exit 1
}

$vercelGridEnd = Find-MatchingCloseDiv $vercelHTML $vercelGridStart
if ($vercelGridEnd -eq -1) {
    Write-Host "ERROR: Could not find closing div for vercel grid"
    exit 1
}

$vercelGrid = $vercelHTML.Substring($vercelGridStart, $vercelGridEnd - $vercelGridStart)
$vercelCardCount = ([regex]::Matches($vercelGrid, 'class="card')).Count
Write-Host "Extracted vercel grid: $($vercelGrid.Length) chars, $vercelCardCount cards"

# --- 2. Extract grid from local ---
$localGridStart = $localHTML.IndexOf('<div class="grid">')
if ($localGridStart -eq -1) {
    Write-Host "ERROR: Could not find grid in index.html"
    exit 1
}

$localGridEnd = Find-MatchingCloseDiv $localHTML $localGridStart
if ($localGridEnd -eq -1) {
    Write-Host "ERROR: Could not find closing div for local grid"
    exit 1
}

$localGrid = $localHTML.Substring($localGridStart, $localGridEnd - $localGridStart)
$localCardCount = ([regex]::Matches($localGrid, 'class="card')).Count
Write-Host "Local grid: $($localGrid.Length) chars, $localCardCount cards"

# --- 3. Extract vouch section from vercel ---
$vercelVouchIdx = $vercelHTML.IndexOf('class="vouch-grid"')
$vercelVouchHTML = $null
if ($vercelVouchIdx -gt -1) {
    $vdivStart = $vercelHTML.LastIndexOf('<div', $vercelVouchIdx)
    $vdivEnd = Find-MatchingCloseDiv $vercelHTML $vdivStart
    if ($vdivEnd -gt -1) {
        $vercelVouchHTML = $vercelHTML.Substring($vdivStart, $vdivEnd - $vdivStart)
        Write-Host "Extracted vercel vouch grid: $($vercelVouchHTML.Length) chars"
    }
}

# --- 4. Mark sold out cards ---
$soldOutOverlay = '<div class="card-pill">&#10060; Sold Out</div><div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:''Bebas Neue'',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'

function Mark-SoldOut {
    param([string]$html, [string]$searchText)
    
    $idx = $html.IndexOf($searchText)
    if ($idx -eq -1) {
        Write-Host "WARNING: Could not find '$searchText'"
        return $html
    }
    
    # Find card start
    $cardStart = $html.LastIndexOf('<div class="card', $idx)
    if ($cardStart -eq -1) {
        Write-Host "WARNING: Could not find card div for '$searchText'"
        return $html
    }
    
    # Find end of opening tag
    $tagEnd = $html.IndexOf('>', $cardStart)
    $cardTag = $html.Substring($cardStart, $tagEnd + 1 - $cardStart)
    
    # Update data-status
    if ($cardTag -match 'data-status=') {
        $newCardTag = $cardTag -replace 'data-status="[^"]*"', 'data-status="sold"'
    } else {
        $newCardTag = $cardTag -replace 'class="card', 'data-status="sold" class="card'
    }
    
    # Check if already has sold overlay
    $afterLen = [Math]::Min(200, $html.Length - $tagEnd - 1)
    $afterTag = $html.Substring($tagEnd + 1, $afterLen)
    if ($afterTag -match 'Sold Out|SOLD OUT') {
        Write-Host "Already has sold overlay: '$searchText'"
        return $html
    }
    
    $result = $html.Substring(0, $cardStart) + $newCardTag + "`n      " + $soldOutOverlay + $html.Substring($tagEnd + 1)
    Write-Host "Marked SOLD OUT: '$searchText'"
    return $result
}

$finalGrid = $vercelGrid

# Try both HTML entity and plain versions
$changed = $false
foreach ($search in @('Reaver 2.0, Primordium &amp; Kuronami', 'Reaver 2.0, Primordium & Kuronami')) {
    $newGrid = Mark-SoldOut $finalGrid $search
    if ($newGrid -ne $finalGrid) {
        $finalGrid = $newGrid
        $changed = $true
        break
    }
}

$changed = $false
foreach ($search in @('Kuronami, Narukami &amp; Champs 25', 'Kuronami, Narukami & Champs 25')) {
    $newGrid = Mark-SoldOut $finalGrid $search
    if ($newGrid -ne $finalGrid) {
        $finalGrid = $newGrid
        $changed = $true
        break
    }
}

# --- 5. Replace grid in local HTML ---
$newHTML = $localHTML.Substring(0, $localGridStart) + $finalGrid + $localHTML.Substring($localGridEnd)

# --- 6. Replace vouch grid ---
if ($vercelVouchHTML) {
    $localVouchIdx = $newHTML.IndexOf('class="vouch-grid"')
    if ($localVouchIdx -gt -1) {
        $lvStart = $newHTML.LastIndexOf('<div', $localVouchIdx)
        $lvEnd = Find-MatchingCloseDiv $newHTML $lvStart
        if ($lvEnd -gt -1) {
            $newHTML = $newHTML.Substring(0, $lvStart) + $vercelVouchHTML + $newHTML.Substring($lvEnd)
            Write-Host "Replaced vouch grid"
        }
    }
}

# --- 7. Write output ---
[System.IO.File]::WriteAllText("$PSScriptRoot\index.html", $newHTML, [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "=== DONE ==="
Write-Host "New index.html: $($newHTML.Length) chars"
