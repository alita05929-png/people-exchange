const fs = require("fs");
const html = fs.readFileSync("E:/pack/bsc/2/index.html", "utf8");
const i = html.indexOf("The ticker");
console.log(JSON.stringify(html.slice(i, i + 1400)));
