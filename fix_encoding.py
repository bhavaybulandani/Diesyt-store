import os

files_to_fix = [
    r"c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\index.html",
    r"c:\Users\diesy\.gemini\antigravity\scratch\diesyt_store\accounts.html"
]

replacements = {
    '<span class="why-icon">???</span>': '<span class="why-icon">🛡️</span>',
    '<span class="why-icon">?</span>': '<span class="why-icon">⚡</span>',
    '<span class="why-icon">??</span>': '<span class="why-icon">💎</span>',
    '<div class="stat-num">? Instant</div>': '<div class="stat-num">⚡ Instant</div>',
    '&ccounts': 'Accounts',
    '&bout': 'About',
    '&LL': 'ALL',
    'V&LOR&NT': 'VALORANT',
    'INDI&\'S': "INDIA'S",
    'M&RKETPL&CE': 'MARKETPLACE',
    '&CCOUNTS': 'ACCOUNTS',
    'V&LOR&NT': 'VALORANT'
}

for file_path in files_to_fix:
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Failed to read {file_path}: {e}")
        continue

    for old, new in replacements.items():
        content = content.replace(old, new)
        
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Replacement complete.")
