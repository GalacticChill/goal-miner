#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

function findRelativeLinks(markdown) {
  const re = /\[[^\]]*\]\(([^)\s#]+)(?:#[^)]*)?\)/g;
  const links = [];
  let m;
  while ((m = re.exec(markdown))) if (!/^[a-z]+:/i.test(m[1])) links.push(m[1]);
  return links;
}

function brokenLinks(file) {
  const dir = path.dirname(file);
  return findRelativeLinks(fs.readFileSync(file, "utf8")).filter(
    (l) => !fs.existsSync(path.resolve(dir, l))
  );
}

module.exports = { findRelativeLinks, brokenLinks };

if (require.main === module) {
  const file = process.argv[2];
  const broken = brokenLinks(file);
  broken.forEach((l) => console.log(`${file}: broken link ${l}`));
  process.exit(broken.length ? 1 : 0);
}
