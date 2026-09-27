const fs = require("fs");
const path = require("path");
const root = "E:/pack/bsc/2";
const files = [
  "index.html",
  "ecosystem/index.html",
  "holding/index.html",
  "academy/index.html",
];
const set = new Set();
for (const f of files) {
  const text = fs.readFileSync(path.join(root, f), "utf8");
  const re = /(?:src|data-lazy-src|data-src|href|content|srcset|data-lazy-srcset)=["']([^"']+\.(?:png|jpe?g|webp|gif|svg|mp4|webm))/gi;
  let m;
  while ((m = re.exec(text))) {
    const u = m[1].split(" ")[0];
    if (/broccoli|f3b|logo|banner|favicon|giggle|ecosystem-cover|bone|winner|iphone|funding|placeholder/i.test(u)) {
      set.add(f + " :: " + u);
    }
  }
  const bg = /url\(([^)]+\.(?:png|jpe?g|webp|gif|svg))/gi;
  while ((m = bg.exec(text))) {
    const u = m[1].replace(/['"]/g, "");
    if (/broccoli|f3b|logo|banner|favicon|giggle|ecosystem|bone|winner/i.test(u)) {
      set.add(f + " BG :: " + u);
    }
  }
}
console.log([...set].sort().join("\n"));
