const fs = require("fs");
const path = require("path");
const root = "E:/pack/bsc/2";

function extract(file) {
  let text = fs.readFileSync(file, "utf8");
  text = text.replace(/<script[\s\S]*?<\/script>/gi, " ");
  text = text.replace(/<style[\s\S]*?<\/style>/gi, " ");
  const re = /<(h[1-6]|p|title)[^>]*>([\s\S]*?)<\/\1>/gi;
  const seen = new Set();
  console.log("\n==== " + path.relative(root, file) + " ====");
  let m;
  while ((m = re.exec(text))) {
    let clean = m[2]
      .replace(/<[^>]+>/g, "")
      .replace(/&nbsp;/g, " ")
      .replace(/&amp;/g, "&")
      .replace(/&#038;/g, "&")
      .replace(/\s+/g, " ")
      .trim();
    if (!clean || clean.length > 400) continue;
    const key = clean.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    console.log("[" + m[1] + "] " + clean.slice(0, 320));
  }
}

for (const f of [
  "index.html",
  "ecosystem/index.html",
  "holding/index.html",
  "academy/index.html",
]) {
  extract(path.join(root, f));
}
