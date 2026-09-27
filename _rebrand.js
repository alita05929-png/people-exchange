const fs = require("fs");

const pages = [
  { file: "index.html", css: "./brand.css", home: "./index.html" },
  { file: "academy/index.html", css: "../brand.css", home: "../index.html" },
  { file: "holding/index.html", css: "../brand.css", home: "../index.html" },
  { file: "ecosystem/index.html", css: "../brand.css", home: "../index.html" },
];

function patch(file, css, home) {
  let t = fs.readFileSync(file, "utf8");

  if (!t.includes("brand.css")) {
    t = t.replace("<title>", `<link rel="stylesheet" href="${css}" />\n\t<title>`);
  }

  t = t.replace(/et_hide_primary_logo\s+/g, "");
  t = t.replace(/et_hide_fixed_logo\s+/g, "");
  t = t.replace(/et_hide_mobile_logo\s+/g, "");

  t = t.replaceAll("$人民交易所", "$货币自由");
  t = t.replaceAll("https://人民交易所", home);

  const swaps = [
    ["人民交易所 | People's Exchange", "Freedom of Money | 货币自由"],
    ["Academy | 人民交易所", "Academy | Freedom of Money"],
    ["Holding | 人民交易所", "Holding | Freedom of Money"],
    ["Ecosystem | 人民交易所", "Ecosystem | Freedom of Money"],
    ['alt="人民交易所"', 'alt="Freedom of Money"'],
    [
      "Name and ticker: 人民交易所. The people’s exchange — a community-owned token on BNB Chain.",
      "Name: Freedom of Money. Ticker: 货币自由. A community token on BNB Chain.",
    ],
    ["welcome to 人民交易所", "welcome to Freedom of Money"],
    [
      "The ticker and name “人民交易所” are on BNB Chain through the FOUR.MEME platform. The project is fully community-managed and owned.",
      "The name is Freedom of Money and the ticker is 货币自由. Both are on BNB Chain through the FOUR.MEME platform. The project is fully community-managed and owned.",
    ],
    [
      "This is the people’s exchange: one name, one ticker, and a market built to bring people together.",
      "One name, one ticker, and a market built so people can move value freely.",
    ],
    [
      "We work with partners across Binance and BNB Chain. 人民交易所 is the figurehead of this movement — education, outreach, onboarding, and tools that make the ecosystem better for everyone.",
      "We work with partners across Binance and BNB Chain. Freedom of Money stands for this movement — education, outreach, onboarding, and tools that make the ecosystem better for everyone.",
    ],
    [
      "Binance and BNB Chain are home for this market, and the community is building 人民交易所 in that chapter.",
      "Binance and BNB Chain are home for this market, and the community is building Freedom of Money in that chapter.",
    ],
    [
      "人民交易所 has communities around the world and a presence on Binance Square. Follow along for news and updates.",
      "Freedom of Money has communities around the world and a presence on Binance Square. Follow along for news and updates.",
    ],
    [
      "人民交易所 is deployed on BNB Chain through the Four.meme platform. The goal is a community token people can gather around — a shared exchange, not only hype.",
      "Freedom of Money is deployed on BNB Chain through the Four.meme platform. The goal is a community token people can gather around — money that moves freely, not only hype.",
    ],
    [
      "Join the movement and build the people’s exchange with us — one name and one ticker: 人民交易所.",
      "Join the movement and build with us — the name is Freedom of Money and the ticker is 货币自由.",
    ],
    ["THE PEOPLE’S EXCHANGE ON BNB CHAIN", "FREEDOM OF MONEY ON BNB CHAIN"],
    [
      "人民交易所 is the community token. The mark is the gold diamond. The name is 人民交易所. The ticker is 人民交易所. It launched on FOUR.MEME for people who want a shared exchange on BNB Chain.",
      "Freedom of Money is the community token. The mark is the gold diamond. The name is Freedom of Money. The ticker is 货币自由. It launched on FOUR.MEME for people who want money that moves freely on BNB Chain.",
    ],
    [
      "人民交易所 has an extensive and ever-growing network of partners and integrations.",
      "Freedom of Money has an extensive and ever-growing network of partners and integrations.",
    ],
    [
      "Binance is SAFU. People’s exchange. Intern got promoted.",
      "Freedom of Money. Ticker 货币自由. On BNB Chain.",
    ],
    [
      "At the harvest festival, one trader takes more than their share. 人民交易所 is a reminder that a market stays full when people give as well as take.",
      "A market stays open when people can move value freely. Freedom of Money is a reminder that access, not permission, keeps the exchange alive.",
    ],
    [
      "Builders write the market together. Shared rules and fair choices create something that belongs to everyone: 人民交易所.",
      "Builders write the market together. Shared rules and fair choices create something that belongs to everyone: Freedom of Money.",
    ],
    [
      "Join 人民交易所, a playful pup, on a magical adventure! With his friends Four and Tri-Fang, he builds, solves puzzles, and wins a big challenge. But the journey isn’t over—there’s more to explore! Are you ready to join the fun?",
      "Freedom of Money is a market anyone can join. The gold diamond marks the way, and the ticker is 货币自由. Build, trade, and keep going — there is more ahead.",
    ],
  ];

  for (const [from, to] of swaps) {
    if (!t.includes(from) && file === "index.html" && from.includes("welcome")) {
      console.log("MISSING in", file, from.slice(0, 60));
    }
    t = t.split(from).join(to);
  }

  if (t.includes("人民交易所")) {
    console.log("leftover 人民交易所 in", file, (t.match(/人民交易所/g) || []).length);
    t = t.split("人民交易所").join("Freedom of Money");
  }
  if (t.includes("People’s exchange") || t.includes("People's Exchange")) {
    t = t.split("People’s exchange").join("Freedom of Money");
    t = t.split("People's Exchange").join("Freedom of Money");
  }

  const heroOld =
    '<style id="renmin-hero">.et_pb_fullwidth_header_0{background-color:#050505!important;background-repeat:no-repeat!important;background-position:center 3vh!important;background-size:auto 64vh!important;min-height:93vh!important}.et_pb_fullwidth_header_0 .header-logo,.et_pb_fullwidth_header_0 .et_pb_header_content_wrapper{display:none!important}.et_pb_fullwidth_header_0 .header-content{position:absolute;left:0;right:0;bottom:2.5vh;text-align:center;z-index:4}.et_pb_fullwidth_header_0 .et_pb_button{margin:0 8px!important}.et_pb_fullwidth_header_0 .et_pb_fullwidth_header_scroll{display:none!important}</style>';
  const heroNew = `<style id="renmin-hero">
.et_pb_fullwidth_header_0{background-color:#050505!important;background-image:url(./wp-content/uploads/2025/04/broccoli-cyberpunk-city-hq-02-placeholder.jpg)!important;background-repeat:no-repeat!important;background-position:center center!important;background-size:cover!important;min-height:100vh!important;min-height:100dvh!important}
.et_pb_fullwidth_header_0 .et_pb_fullwidth_header_overlay{background:linear-gradient(to bottom,rgba(0,0,0,.45) 0%,rgba(0,0,0,0) 22%,rgba(0,0,0,0) 68%,rgba(0,0,0,.55) 100%)}
.et_pb_fullwidth_header_0 .header-logo,.et_pb_fullwidth_header_0 .et_pb_header_content_wrapper{display:none!important}
.et_pb_fullwidth_header_0 .header-content{position:absolute;left:0;right:0;bottom:5vh;text-align:center;z-index:4}
.et_pb_fullwidth_header_0 .et_pb_button{margin:0 8px 8px!important}
.et_pb_fullwidth_header_0 .et_pb_fullwidth_header_scroll{display:none!important}
@media (max-width:767px){
  .et_pb_fullwidth_header_0{min-height:78vh!important;background-position:center 40%!important}
  .et_pb_fullwidth_header_0 .header-content{bottom:3vh}
}
</style>`;
  if (t.includes(heroOld)) t = t.replace(heroOld, heroNew);
  else if (file === "index.html") console.log("hero style block not found");

  fs.writeFileSync(file, t);
  console.log("updated", file);
}

for (const p of pages) patch(p.file, p.css, p.home);
