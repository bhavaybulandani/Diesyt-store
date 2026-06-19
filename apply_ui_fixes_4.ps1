$cssAppend = @"

/* --- UI FIXES BATCH 4 - 3D BUTTONS --- */

/* BUY ON WHATSAPP BUTTONS */
.card-buy, .btn-whatsapp, .buy-btn, [class*="whatsapp"], [class*="buy-btn"] {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  padding: 11px 22px !important;
  background: linear-gradient(180deg, #B06EFF 0%, #7B2FBE 50%, #5B1A9A 100%) !important;
  color: #ffffff !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 13px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 6px !important;
  text-decoration: none !important;
  border: none !important;
  cursor: pointer !important;

  /* 3D effect */
  border-top: 1px solid rgba(255, 255, 255, 0.35) !important;
  border-left: 1px solid rgba(255, 255, 255, 0.15) !important;
  border-right: 1px solid rgba(80, 0, 160, 0.6) !important;
  border-bottom: 3px solid #3A0080 !important;

  /* Glow + depth shadow */
  box-shadow: 
    0 4px 15px rgba(147, 51, 234, 0.4),
    0 8px 25px rgba(147, 51, 234, 0.2),
    inset 0 1px 0 rgba(255, 255, 255, 0.2) !important;

  transition: all 0.15s ease !important;
  white-space: nowrap !important;
  min-width: auto !important;
  width: auto !important;
}

.card-buy:hover, .btn-whatsapp:hover, .buy-btn:hover {
  background: linear-gradient(180deg, #C080FF 0%, #9333EA 50%, #6B1FBE 100%) !important;
  box-shadow: 
    0 6px 20px rgba(147, 51, 234, 0.55),
    0 10px 30px rgba(147, 51, 234, 0.25),
    inset 0 1px 0 rgba(255, 255, 255, 0.25) !important;
  transform: translateY(-1px) !important;
  border-bottom: 3px solid #4A00A0 !important;
}

.card-buy:active, .btn-whatsapp:active, .buy-btn:active {
  transform: translateY(1px) !important;
  border-bottom: 1px solid #3A0080 !important;
  box-shadow: 
    0 2px 8px rgba(147, 51, 234, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
}

/* OTHER SPECIFIC BUTTONS (Apply the same 3D base style) */
.btn-gold, .nav-btn, .btn-arsenal {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  padding: 11px 22px !important;
  background: linear-gradient(180deg, #B06EFF 0%, #7B2FBE 50%, #5B1A9A 100%) !important;
  color: #ffffff !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 13px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 6px !important;
  text-decoration: none !important;
  border: none !important;
  cursor: pointer !important;
  
  border-top: 1px solid rgba(255, 255, 255, 0.35) !important;
  border-left: 1px solid rgba(255, 255, 255, 0.15) !important;
  border-right: 1px solid rgba(80, 0, 160, 0.6) !important;
  border-bottom: 3px solid #3A0080 !important;

  box-shadow: 
    0 4px 15px rgba(147, 51, 234, 0.4),
    0 8px 25px rgba(147, 51, 234, 0.2),
    inset 0 1px 0 rgba(255, 255, 255, 0.2) !important;

  transition: all 0.15s ease !important;
  white-space: nowrap !important;
  min-width: auto !important;
  width: auto !important;
}

.btn-gold:hover, .nav-btn:hover, .btn-arsenal:hover {
  background: linear-gradient(180deg, #C080FF 0%, #9333EA 50%, #6B1FBE 100%) !important;
  box-shadow: 
    0 6px 20px rgba(147, 51, 234, 0.55),
    0 10px 30px rgba(147, 51, 234, 0.25),
    inset 0 1px 0 rgba(255, 255, 255, 0.25) !important;
  transform: translateY(-1px) !important;
  border-bottom: 3px solid #4A00A0 !important;
}

.btn-gold:active, .nav-btn:active, .btn-arsenal:active {
  transform: translateY(1px) !important;
  border-bottom: 1px solid #3A0080 !important;
  box-shadow: 
    0 2px 8px rgba(147, 51, 234, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
}

/* JOIN COMMUNITY BUTTON (.btn-ghost) */
.btn-ghost {
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  padding: 11px 22px !important;
  background: transparent !important;
  color: #C084FC !important;
  font-family: 'Barlow Condensed', sans-serif !important;
  font-size: 13px !important;
  font-weight: 700 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  border-radius: 6px !important;
  text-decoration: none !important;
  border: 1px solid rgba(147,51,234,0.4) !important;
  border-bottom: 3px solid rgba(147,51,234,0.4) !important;
  cursor: pointer !important;

  box-shadow: none !important;
  transition: all 0.15s ease !important;
  white-space: nowrap !important;
  min-width: auto !important;
  width: auto !important;
}

.btn-ghost:hover {
  background: rgba(147,51,234,0.1) !important;
  box-shadow: 
    0 6px 20px rgba(147, 51, 234, 0.2) !important;
  transform: translateY(-1px) !important;
  border-bottom: 3px solid rgba(147,51,234,0.6) !important;
}

.btn-ghost:active {
  transform: translateY(1px) !important;
  border-bottom: 1px solid rgba(147,51,234,0.4) !important;
  box-shadow: 
    0 2px 8px rgba(147, 51, 234, 0.1) !important;
}

/* FILTER BUTTONS */
.filter-btn {
  border-bottom: 2px solid rgba(0,0,0,0.4) !important;
  box-shadow: 0 3px 8px rgba(0,0,0,0.3) !important;
  transition: all 0.15s ease !important;
}
.filter-btn:active {
  transform: translateY(1px) !important;
  border-bottom: 0px solid rgba(0,0,0,0.4) !important;
  box-shadow: 0 1px 4px rgba(0,0,0,0.3) !important;
}
"@

$cssPath = "c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\app\css\style.css"
$cssContent = [IO.File]::ReadAllText($cssPath)
$cssContent += $cssAppend
[IO.File]::WriteAllText($cssPath, $cssContent)
