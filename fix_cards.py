import re

# Read both files
with open('vercel_index.html', 'r', encoding='utf-8') as f:
    vercel_html = f.read()
with open('index.html', 'r', encoding='utf-8') as f:
    local_html = f.read()

def find_matching_close_div(html, start_idx):
    """Find the matching closing </div> for the <div at start_idx"""
    depth = 0
    i = start_idx
    while i < len(html):
        if html[i:i+4] == '<div':
            depth += 1
        elif html[i:i+6] == '</div>':
            depth -= 1
            if depth == 0:
                return i + 6
        i += 1
    return -1

# --- 1. Extract grid from vercel ---
vercel_grid_start = vercel_html.find('<div class="grid">')
if vercel_grid_start == -1:
    # Try single quotes
    vercel_grid_start = vercel_html.find("<div class='grid'>")
    if vercel_grid_start == -1:
        print("ERROR: Could not find grid in vercel_index.html")
        # Look for card classes to debug
        card_idx = vercel_html.find('class="card')
        if card_idx > -1:
            print(f"Found card at index {card_idx}")
            print(f"Context: ...{vercel_html[max(0,card_idx-300):card_idx+50]}...")
        exit(1)

vercel_grid_end = find_matching_close_div(vercel_html, vercel_grid_start)
if vercel_grid_end == -1:
    print("ERROR: Could not find closing div for vercel grid")
    exit(1)

vercel_grid = vercel_html[vercel_grid_start:vercel_grid_end]
vercel_card_count = vercel_grid.count('class="card')
print(f"Extracted vercel grid: {len(vercel_grid)} chars, {vercel_card_count} cards")

# --- 2. Extract grid from local ---
local_grid_start = local_html.find('<div class="grid">')
if local_grid_start == -1:
    print("ERROR: Could not find grid in index.html")
    exit(1)

local_grid_end = find_matching_close_div(local_html, local_grid_start)
if local_grid_end == -1:
    print("ERROR: Could not find closing div for local grid")
    exit(1)

local_grid = local_html[local_grid_start:local_grid_end]
local_card_count = local_grid.count('class="card')
print(f"Local grid: {len(local_grid)} chars, {local_card_count} cards")

# --- 3. Extract vouch section from vercel ---
vercel_vouch_idx = vercel_html.find('class="vouch-grid"')
vercel_vouch_html = None
if vercel_vouch_idx > -1:
    vdiv_start = vercel_html.rfind('<div', 0, vercel_vouch_idx)
    vdiv_end = find_matching_close_div(vercel_html, vdiv_start)
    if vdiv_end > -1:
        vercel_vouch_html = vercel_html[vdiv_start:vdiv_end]
        print(f"Extracted vercel vouch grid: {len(vercel_vouch_html)} chars")

# --- 4. Add sold-out overlays ---
sold_out_overlay = '''<div class="card-pill">❌ Sold Out</div><div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:'Bebas Neue',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'''

def mark_sold_out(html, search_text):
    idx = html.find(search_text)
    if idx == -1:
        print(f"WARNING: Could not find '{search_text}'")
        return html
    
    # Find the card start
    card_start = html.rfind('<div class="card', 0, idx)
    if card_start == -1:
        print(f"WARNING: Could not find card div for '{search_text}'")
        return html
    
    # Find end of opening tag
    tag_end = html.find('>', card_start)
    card_tag = html[card_start:tag_end+1]
    
    # Update data-status
    if 'data-status=' in card_tag:
        new_card_tag = re.sub(r'data-status="[^"]*"', 'data-status="sold"', card_tag)
    else:
        new_card_tag = card_tag.replace('class="card', 'data-status="sold" class="card')
    
    # Check if already has sold overlay
    after_tag = html[tag_end+1:tag_end+201]
    if 'Sold Out' in after_tag or 'SOLD OUT' in after_tag:
        print(f"Already has sold overlay: '{search_text}'")
        return html
    
    html = html[:card_start] + new_card_tag + '\n      ' + sold_out_overlay + html[tag_end+1:]
    print(f"Marked SOLD OUT: '{search_text}'")
    return html

final_grid = vercel_grid

# Try with &amp; first (HTML entity), then with &
for search in ['Reaver 2.0, Primordium &amp; Kuronami', 'Reaver 2.0, Primordium & Kuronami']:
    new_grid = mark_sold_out(final_grid, search)
    if new_grid != final_grid:
        final_grid = new_grid
        break

for search in ['Kuronami, Narukami &amp; Champs 25', 'Kuronami, Narukami & Champs 25']:
    new_grid = mark_sold_out(final_grid, search)
    if new_grid != final_grid:
        final_grid = new_grid
        break

# --- 5. Replace grid in local HTML ---
new_html = local_html[:local_grid_start] + final_grid + local_html[local_grid_end:]

# --- 6. Replace vouch grid ---
if vercel_vouch_html:
    local_vouch_idx = new_html.find('class="vouch-grid"')
    if local_vouch_idx > -1:
        lv_start = new_html.rfind('<div', 0, local_vouch_idx)
        lv_end = find_matching_close_div(new_html, lv_start)
        if lv_end > -1:
            new_html = new_html[:lv_start] + vercel_vouch_html + new_html[lv_end:]
            print("Replaced vouch grid")

# --- 7. Write output ---
with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print(f"\n=== DONE ===")
print(f"New index.html: {len(new_html)} chars")
