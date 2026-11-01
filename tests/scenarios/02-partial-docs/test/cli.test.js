const { findRelativeLinks } = require("../src/cli");

test("finds relative links and skips URLs", () => {
  const md = "[a](./a.md) [b](https://x.com) [c](docs/c.md#intro)";
  expect(findRelativeLinks(md)).toEqual(["./a.md", "docs/c.md"]);
});
