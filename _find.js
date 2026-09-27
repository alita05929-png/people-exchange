const fs = require("fs");
const html = fs.readFileSync("E:/pack/bsc/2/index.html", "utf8");
const keys = ["fullwidth_header_0", "header-logo", "min-height", "logo-1"];
for (const k of ["et_pb_fullwidth_header_0{", ".header-logo{", "et_pb_fullwidth_header_0 "]) {
  let i = 0, n = 0;
  while ((i = html.indexOf(k, i)) !== -1 && n < 3) {
    console.log("\n---", k, i, "---");
    console.log(html.slice(i, i + 500));
    i += k.length;
    n++;
  }
}
