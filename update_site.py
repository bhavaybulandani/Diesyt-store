import re

def update_html(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern for Kuronami
    pattern_kuronami = r'(<div class="card reveal" data-status=")available(".*?>\s*<div class="card-pill".*?>)(.*?)(</div>\s*<div class="card-thumb".*?>.*?<h3 class="card-name">Kuronami, Narukami & Champs 25</h3>)'
    replacement_kuronami = r'\1sold\2 style="background:linear-gradient(135deg,#e74c3c,#c0392b);color:#fff;">❌ Sold Out\4<div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:\'Bebas Neue\',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'
    content = re.sub(pattern_kuronami, replacement_kuronami, content, flags=re.DOTALL)

    # Pattern for Reaver
    pattern_reaver = r'(<div class="card reveal" data-status=")available(".*?>\s*<div class="card-pill".*?>)(.*?)(</div>\s*<div class="card-thumb".*?>.*?<h3 class="card-name">Reaver 2\.0, Primordium & Kuronami</h3>)'
    replacement_reaver = r'\1sold\2 style="background:linear-gradient(135deg,#e74c3c,#c0392b);color:#fff;">❌ Sold Out\4<div style="position:absolute;inset:0;background:rgba(0,0,0,0.6);z-index:10;display:flex;align-items:center;justify-content:center;pointer-events:none;"><span style="font-family:\'Bebas Neue\',sans-serif;font-size:1.1rem;font-weight:700;color:#e74c3c;letter-spacing:0.15em;border:2px solid #e74c3c;padding:0.4rem 1.2rem;">SOLD OUT</span></div>'
    content = re.sub(pattern_reaver, replacement_reaver, content, flags=re.DOTALL)

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

update_html('index.html')
update_html('accounts.html')

with open('style.css', 'r', encoding='utf-8') as f:
    css = f.read()

css = re.sub(r'\.logo-img\s*\{\s*height:\s*35px;', r'.logo-img { height: 60px;', css)
css = re.sub(r'opacity:\s*0\.15;\s*', r'opacity: 0.05; mix-blend-mode: screen;', css)

with open('style.css', 'w', encoding='utf-8') as f:
    f.write(css)

print("Done")
