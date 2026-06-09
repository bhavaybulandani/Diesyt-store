const fs = require('fs');

function updateHtml(filename) {
    let content = fs.readFileSync(filename, 'utf-8');

    // Pattern for Kuronami
    const patternKuronami = /(<div class="card reveal" data-status=")available(".*?>\s*<div class="card-pill".*?>)(.*?)(<\/div>\s*<div class="card-thumb".*?>.*?<h3 class="card-name">Kuronami, Narukami & Champs 25<\/h3>)/s;
    const replacementKuronami = `$1sold$2 style="background:linear-gradient(135deg,#e74c3c,#c0392b);color:#fff;">❌ Sold Out$4<div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:'Bebas Neue',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>`;
    content = content.replace(patternKuronami, replacementKuronami);

    // Pattern for Reaver
    const patternReaver = /(<div class="card reveal" data-status=")available(".*?>\s*<div class="card-pill".*?>)(.*?)(<\/div>\s*<div class="card-thumb".*?>.*?<h3 class="card-name">Reaver 2\.0, Primordium & Kuronami<\/h3>)/s;
    const replacementReaver = `$1sold$2 style="background:linear-gradient(135deg,#e74c3c,#c0392b);color:#fff;">❌ Sold Out$4<div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:'Bebas Neue',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>`;
    content = content.replace(patternReaver, replacementReaver);

    fs.writeFileSync(filename, content, 'utf-8');
}

updateHtml('index.html');
updateHtml('accounts.html');

let css = fs.readFileSync('style.css', 'utf-8');
css = css.replace(/\.logo-img\s*\{\s*height:\s*35px;/g, '.logo-img { height: 60px;');
css = css.replace(/opacity:\s*0\.15;\s*/g, 'opacity: 0.05; mix-blend-mode: screen;');
fs.writeFileSync('style.css', css, 'utf-8');

console.log('Done');
