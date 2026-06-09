const fs = require('fs');

// Read both files
const vercelHTML = fs.readFileSync('vercel_index.html', 'utf8');
const localHTML = fs.readFileSync('index.html', 'utf8');

// --- 1. Extract the grid from vercel ---
// Find <div class="grid"> ... </div> that closes the grid (before </section>)
const vercelGridStart = vercelHTML.indexOf('<div class="grid">');
if (vercelGridStart === -1) {
  console.log('ERROR: Could not find <div class="grid"> in vercel_index.html');
  // Try alternate class names
  const alt1 = vercelHTML.indexOf('class="grid"');
  const alt2 = vercelHTML.indexOf("class='grid'");
  console.log('Alt search class="grid":', alt1);
  console.log("Alt search class='grid':", alt2);
  
  // Search for card patterns
  const cardIdx = vercelHTML.indexOf('class="card');
  console.log('First card class index:', cardIdx);
  if (cardIdx > -1) {
    console.log('Context around first card:', vercelHTML.substring(Math.max(0, cardIdx-200), cardIdx+100));
  }
  process.exit(1);
}

// Find the closing </div> for the grid - it's the one right before </section> or the "Choose Your Arsenal" style div
// We need to find the matching closing div. Let's find it by counting open/close divs
let depth = 0;
let vercelGridEnd = -1;
for (let i = vercelGridStart; i < vercelHTML.length; i++) {
  if (vercelHTML.substring(i, i+4) === '<div') {
    depth++;
  } else if (vercelHTML.substring(i, i+6) === '</div>') {
    depth--;
    if (depth === 0) {
      vercelGridEnd = i + 6;
      break;
    }
  }
}

if (vercelGridEnd === -1) {
  console.log('ERROR: Could not find closing </div> for grid');
  process.exit(1);
}

const vercelGrid = vercelHTML.substring(vercelGridStart, vercelGridEnd);
console.log('Extracted vercel grid, length:', vercelGrid.length);
console.log('Grid starts with:', vercelGrid.substring(0, 200));
console.log('Grid ends with:', vercelGrid.substring(vercelGrid.length - 200));

// Count cards in vercel grid
const vercelCardCount = (vercelGrid.match(/class="card/g) || []).length;
console.log('Number of cards in vercel grid:', vercelCardCount);

// --- 2. Extract the grid from local ---
const localGridStart = localHTML.indexOf('<div class="grid">');
if (localGridStart === -1) {
  console.log('ERROR: Could not find <div class="grid"> in index.html');
  process.exit(1);
}

let localDepth = 0;
let localGridEnd = -1;
for (let i = localGridStart; i < localHTML.length; i++) {
  if (localHTML.substring(i, i+4) === '<div') {
    localDepth++;
  } else if (localHTML.substring(i, i+6) === '</div>') {
    localDepth--;
    if (localDepth === 0) {
      localGridEnd = i + 6;
      break;
    }
  }
}

if (localGridEnd === -1) {
  console.log('ERROR: Could not find closing </div> for local grid');
  process.exit(1);
}

const localGrid = localHTML.substring(localGridStart, localGridEnd);
const localCardCount = (localGrid.match(/class="card/g) || []).length;
console.log('Number of cards in local grid:', localCardCount);

// --- 3. Now extract the vouch section from vercel ---
// Find the vouch-grid
const vercelVouchStart = vercelHTML.indexOf('class="vouch-grid"');
let vercelVouchSection = null;
let vercelVouchSectionHTML = null;

if (vercelVouchStart > -1) {
  // Back up to find the <div
  let vouchDivStart = vercelHTML.lastIndexOf('<div', vercelVouchStart);
  let vDepth = 0;
  let vouchDivEnd = -1;
  for (let i = vouchDivStart; i < vercelHTML.length; i++) {
    if (vercelHTML.substring(i, i+4) === '<div') {
      vDepth++;
    } else if (vercelHTML.substring(i, i+6) === '</div>') {
      vDepth--;
      if (vDepth === 0) {
        vouchDivEnd = i + 6;
        break;
      }
    }
  }
  if (vouchDivEnd > -1) {
    vercelVouchSectionHTML = vercelHTML.substring(vouchDivStart, vouchDivEnd);
    console.log('Extracted vercel vouch grid, length:', vercelVouchSectionHTML.length);
  }
}

// Find the local vouch-grid
const localVouchStart = localHTML.indexOf('class="vouch-grid"');
let localVouchSectionHTML = null;
let localVouchDivStart = -1;
let localVouchDivEnd = -1;

if (localVouchStart > -1) {
  localVouchDivStart = localHTML.lastIndexOf('<div', localVouchStart);
  let lvDepth = 0;
  for (let i = localVouchDivStart; i < localHTML.length; i++) {
    if (localHTML.substring(i, i+4) === '<div') {
      lvDepth++;
    } else if (localHTML.substring(i, i+6) === '</div>') {
      lvDepth--;
      if (lvDepth === 0) {
        localVouchDivEnd = i + 6;
        break;
      }
    }
  }
  if (localVouchDivEnd > -1) {
    localVouchSectionHTML = localHTML.substring(localVouchDivStart, localVouchDivEnd);
    console.log('Extracted local vouch grid, length:', localVouchSectionHTML.length);
  }
}

// --- 4. Now apply the sold-out overlays to the vercel grid for the specific accounts ---
// Mark these as sold out:
// 1. "Reaver 2.0, Primordium & Kuronami"
// 2. "Kuronami, Narukami & Champs 25"
let finalGrid = vercelGrid;

// Apply sold-out overlay to specific cards
const soldOutOverlay = `<div class="card-pill">❌ Sold Out</div><div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:'Bebas Neue',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>`;

// Helper: Find a card containing specific text and add sold-out overlay
function markSoldOut(html, searchText) {
  const idx = html.indexOf(searchText);
  if (idx === -1) {
    console.log('WARNING: Could not find card with text:', searchText);
    return html;
  }
  
  // Find the card start (go backwards to find <div class="card)
  let cardStart = html.lastIndexOf('<div class="card', idx);
  if (cardStart === -1) {
    console.log('WARNING: Could not find card div start for:', searchText);
    return html;
  }
  
  // Update data-status to "sold"
  const cardTagEnd = html.indexOf('>', cardStart);
  const cardTag = html.substring(cardStart, cardTagEnd + 1);
  let newCardTag = cardTag;
  
  // Replace or add data-status="sold"
  if (newCardTag.includes('data-status=')) {
    newCardTag = newCardTag.replace(/data-status="[^"]*"/, 'data-status="sold"');
  } else {
    newCardTag = newCardTag.replace('class="card', 'data-status="sold" class="card');
  }
  
  // Insert sold-out overlay right after the opening card tag
  const afterCardTag = cardTagEnd + 1;
  const insertPoint = afterCardTag - cardStart;
  
  // Check if there's already a sold-out overlay
  const nextChunk = html.substring(afterCardTag, afterCardTag + 200);
  if (nextChunk.includes('Sold Out') || nextChunk.includes('SOLD OUT')) {
    console.log('Card already has sold-out overlay for:', searchText);
    return html;
  }
  
  html = html.substring(0, cardStart) + newCardTag + '\n      ' + soldOutOverlay + html.substring(afterCardTag);
  
  console.log('Marked as SOLD OUT:', searchText);
  return html;
}

finalGrid = markSoldOut(finalGrid, 'Reaver 2.0, Primordium &amp; Kuronami');
if (finalGrid === vercelGrid) {
  // Try without HTML entities
  finalGrid = markSoldOut(finalGrid, 'Reaver 2.0, Primordium & Kuronami');
}

const afterFirst = finalGrid;
finalGrid = markSoldOut(finalGrid, 'Kuronami, Narukami &amp; Champs 25');
if (finalGrid === afterFirst) {
  finalGrid = markSoldOut(finalGrid, 'Kuronami, Narukami & Champs 25');
}

// --- 5. Replace in local HTML ---
let newHTML = localHTML.substring(0, localGridStart) + finalGrid + localHTML.substring(localGridEnd);

// Replace vouch grid if both exist
if (vercelVouchSectionHTML && localVouchDivStart > -1 && localVouchDivEnd > -1) {
  // Recalculate positions since we changed the HTML
  const newLocalVouchStart = newHTML.indexOf('class="vouch-grid"');
  if (newLocalVouchStart > -1) {
    const newLocalVouchDivStart = newHTML.lastIndexOf('<div', newLocalVouchStart);
    let nvDepth = 0;
    let newLocalVouchDivEnd = -1;
    for (let i = newLocalVouchDivStart; i < newHTML.length; i++) {
      if (newHTML.substring(i, i+4) === '<div') {
        nvDepth++;
      } else if (newHTML.substring(i, i+6) === '</div>') {
        nvDepth--;
        if (nvDepth === 0) {
          newLocalVouchDivEnd = i + 6;
          break;
        }
      }
    }
    if (newLocalVouchDivEnd > -1) {
      newHTML = newHTML.substring(0, newLocalVouchDivStart) + vercelVouchSectionHTML + newHTML.substring(newLocalVouchDivEnd);
      console.log('Replaced vouch grid section');
    }
  }
}

// --- 6. Write output ---
fs.writeFileSync('index.html', newHTML, 'utf8');
console.log('\n=== DONE ===');
console.log('New index.html written successfully!');
console.log('New file size:', newHTML.length);
