const fs = require('fs');

const files = [
    "c:\\Users\\diesy\\.gemini\\antigravity\\scratch\\diesyt_store\\index.html",
    "c:\\Users\\diesy\\.gemini\\antigravity\\scratch\\diesyt_store\\accounts.html"
];

const replacements = {
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
};

for (const file of files) {
    try {
        let content = fs.readFileSync(file, 'utf8');
        for (const [oldStr, newStr] of Object.entries(replacements)) {
            content = content.split(oldStr).join(newStr);
        }
        fs.writeFileSync(file, content, 'utf8');
    } catch (e) {
        console.error("Failed to read/write " + file + ": " + e.message);
    }
}
console.log("Replacement complete.");
