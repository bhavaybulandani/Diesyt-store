$ErrorActionPreference = "Stop"
$path = "$PSScriptRoot\style.css"
$css = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# 1. Optimize Ambient Graphics (body::before, body::after)
# Replace expensive filter: blur(150px) with native radial-gradients which are infinitely faster
$css = $css -replace 'filter:\s*blur\(150px\);', '/* filter removed for perf */'
$css = $css -replace 'background:\s*var\(--neon-purple\);', 'background: radial-gradient(circle, var(--neon-purple) 0%, transparent 70%);'
$css = $css -replace 'background:\s*var\(--neon-purple-light\);', 'background: radial-gradient(circle, var(--neon-purple-light) 0%, transparent 70%);'

# 2. Optimize the noise filter (SVG feTurbulence)
# It's currently on body::after but gets overridden later anyway. Let's just remove the SVG noise if it's there.
$css = $css -replace 'background-image:\s*url\("data:image/svg\+xml.*?"\);', '/* noise removed for perf */'

# 3. Optimize grid animation
# The grid lines animation with masks is heavy. Let's pause it or simplify it.
$css = $css -replace 'animation:\s*gridMove\s*20s\s*linear\s*infinite;', '/* gridMove animation removed for perf */'

# 4. Add will-change to reveal elements to hardware accelerate them
$css = $css -replace '\.reveal\s*\{', '.reveal { will-change: opacity, transform; '

# 5. Optimize backdrop-filter
# Reduce blur radius to improve mobile rendering
$css = $css -replace 'backdrop-filter:\s*blur\(20px\);', 'backdrop-filter: blur(8px);'
$css = $css -replace '-webkit-backdrop-filter:\s*blur\(20px\);', '-webkit-backdrop-filter: blur(8px);'

[System.IO.File]::WriteAllText($path, $css, [System.Text.Encoding]::UTF8)
Write-Host "style.css optimized successfully."
