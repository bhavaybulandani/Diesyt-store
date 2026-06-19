$cssAppend = @"
/* --- UI FIXES BATCH 4 - PREMIUM REALISTIC 3D BUTTONS --- */

.card-buy, .btn-whatsapp, .buy-btn, [class*="whatsapp"], [class*="buy-btn"], .btn-gold, .nav-btn, .btn-arsenal {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  padding: 12px 24px !important;
  background: linear-gradient(180deg, #a855f7 0%, #9333ea 100%) !important;
  color: #ffffff !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 14px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 6px !important;
  text-decoration: none !important;
  border: 1px solid #7e22ce !important;
  border-bottom: 3px solid #581c87 !important;
  cursor: pointer !important;

  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.2), 
    0 4px 6px rgba(0, 0, 0, 0.2),
    0 0 12px rgba(147, 51, 234, 0.1) !important;

  transition: transform 0.1s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.1s ease, background 0.1s ease !important;
  white-space: nowrap !important;
  min-width: auto !important;
  width: auto !important;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3) !important;
}

.card-buy:hover, .btn-whatsapp:hover, .buy-btn:hover, .btn-gold:hover, .nav-btn:hover, .btn-arsenal:hover {
  background: linear-gradient(180deg, #b873f8 0%, #a24bf0 100%) !important;
  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.3), 
    0 6px 10px rgba(0, 0, 0, 0.25),
    0 0 16px rgba(147, 51, 234, 0.2) !important;
  transform: translateY(-1px) !important;
}

.card-buy:active, .btn-whatsapp:active, .buy-btn:active, .btn-gold:active, .nav-btn:active, .btn-arsenal:active {
  background: #9333ea !important;
  border-bottom: 1px solid #581c87 !important;
  transform: translateY(2px) !important;
  box-shadow: 
    inset 0 2px 4px rgba(0, 0, 0, 0.3), 
    0 1px 2px rgba(0, 0, 0, 0.1) !important;
}

/* JOIN COMMUNITY BUTTON */
.btn-ghost {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  padding: 12px 24px !important;
  background: rgba(147, 51, 234, 0.05) !important;
  color: #c084fc !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 14px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 6px !important;
  text-decoration: none !important;
  
  border: 1px solid rgba(147,51,234,0.4) !important;
  border-bottom: 3px solid rgba(147,51,234,0.6) !important;
  cursor: pointer !important;

  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05) !important;
  transition: transform 0.1s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.1s ease, background 0.1s ease !important;
  white-space: nowrap !important;
  min-width: auto !important;
  width: auto !important;
}

.btn-ghost:hover {
  background: rgba(147,51,234,0.12) !important;
  transform: translateY(-1px) !important;
  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.1),
    0 4px 8px rgba(0, 0, 0, 0.15),
    0 0 12px rgba(147, 51, 234, 0.1) !important;
}

.btn-ghost:active {
  transform: translateY(2px) !important;
  border-bottom: 1px solid rgba(147,51,234,0.6) !important;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2) !important;
  background: rgba(147,51,234,0.2) !important;
}

/* FILTER BUTTONS */
.filter-btn {
  border-bottom: 2px solid rgba(0,0,0,0.5) !important;
  box-shadow: 0 2px 4px rgba(0,0,0,0.3) !important;
  transition: transform 0.1s cubic-bezier(0.4, 0, 0.2, 1), border-bottom 0.1s ease, box-shadow 0.1s ease !important;
}
.filter-btn:active {
  transform: translateY(1px) !important;
  border-bottom: 1px solid rgba(0,0,0,0.5) !important;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.4) !important;
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$cssContent = [IO.File]::ReadAllText($cssPath)

# Remove the old UI FIXES BATCH 4 block
$index = $cssContent.IndexOf("/* --- UI FIXES BATCH 4 - 3D BUTTONS --- */")
if ($index -ge 0) {
    $cssContent = $cssContent.Substring(0, $index)
}

$cssContent += "`n" + $cssAppend
[IO.File]::WriteAllText($cssPath, $cssContent)
