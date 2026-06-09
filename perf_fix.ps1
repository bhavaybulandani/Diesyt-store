$ErrorActionPreference = "Stop"
$files = @("accounts.html", "index.html")

foreach ($file in $files) {
    $path = "$PSScriptRoot\$file"
    $html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $original = $html.Length

    # Add loading=lazy decoding=async to img tags missing it
    # First pass: handle img with src="data:image directly
    $html = [regex]::Replace($html, '(<img)(?![^>]*loading=)([^>]*>)', '$1 loading="lazy" decoding="async"$2')
    
    # Clean up any accidental doubles
    $html = $html.Replace('loading="lazy" decoding="async" loading="lazy" decoding="async"', 'loading="lazy" decoding="async"')
    $html = $html.Replace('loading="lazy" loading="lazy"', 'loading="lazy"')

    $lazyCount = ([regex]::Matches($html, 'loading="lazy"')).Count
    [System.IO.File]::WriteAllText($path, $html, [System.Text.Encoding]::UTF8)
    Write-Host "$file`: $original bytes -> $($html.Length) bytes | lazy imgs: $lazyCount"
}
Write-Host "Done."
