# Dry-run scenarios

These runs are interactive, because AskUserQuestion can't be answered in `claude -p`. For each scenario:

```sh
tests/scenarios/setup.sh <scenario>      # copies the seed + .claude/ into a fresh git repo under $TMPDIR
cd "$TMPDIR/goal-miner-<scenario>" && claude
# ...run the invocation, answer the questions...
git status && git diff                   # inspect exactly what changed
bash .claude/skills/goal-miner/scripts/check_goal.sh GOAL.md
```

## 1. Empty repo, one-line idea (`01-empty`)

Invocation: `/goal-miner a CLI that tracks my reading list`

Pass when all of these hold:
- [ ] Inspect happens before any question, and the skill notes that the repo is empty apart from IDEA.txt.
- [ ] The `goal-researcher` subagent is spawned, and its findings show up as `[research]` items with URLs.
- [ ] There are at most 3 AskUserQuestion rounds of at most 4 questions each, and every question has a "(Recommended)" first option.
- [ ] Answering one question with "you decide" produces an `A-n` entry with a reason.
- [ ] GOAL.md has the 8 sections in order and 5–15 tagged ACs, and `check_goal.sh` exits 0.
- [ ] The draft is shown, one revision is offered, and sign-off is requested.
- [ ] `CLAUDE.md` is created containing exactly the one line.
- [ ] `git status` shows only `GOAL.md` and `CLAUDE.md` as new: no code, no Makefile, no package.json.

## 2. Existing repo with partial docs (`02-partial-docs`)

Invocation, with no slash command so it also tests auto-triggering: *"I want to turn this into something shippable — help me scope it."*

Pass when all of these hold:
- [ ] The skill fires without being named.
- [ ] No question asks about the language, runtime, test framework or purpose, all of which the README and package.json answer. Those facts appear as `[user]` items citing the files.
- [ ] Questions focus on real unknowns: external URL checking or not, CI usage, output format, quality bar.
- [ ] The ACs reuse the existing tooling (`npm test`, `jest` test paths), and Verification is an npm- or make-based command.
- [ ] `CLAUDE.md` is created with the line. Running `/goal-miner` again detects the existing GOAL.md, offers amend instead of overwriting, and doesn't duplicate the line.
- [ ] `git diff` shows `src/`, `test/` and `package.json` unchanged.

## 3. Amend after a scope change (`03-amend`)

Invocation: *"We're dropping the export feature and adding sync between my two laptops."*

Pass when all of these hold:
- [ ] The skill picks amend mode (GOAL.md exists, and the message is a scope change).
- [ ] At most one question round, about the change only (for example, the sync mechanism: a file in a synced folder, or git).
- [ ] `git diff GOAL.md`:
  - AC-5 is struck through with a removal reason and date.
  - New sync ACs are numbered AC-8 and up.
  - AC-1–4, 6 and 7 are byte-identical.
  - The RFC 4180 CSV constraint is removed or struck, with the reason recorded.
- [ ] Exactly one new Changelog entry, listing added and removed ACs.
- [ ] `git diff CLAUDE.md` is empty, since the line already existed and the other content is untouched.
- [ ] `check_goal.sh` exits 0.

## 4. Verify, report only (run after scenario 3; no Makefile exists)

Invocation: `/goal-miner verify`

Pass when all of these hold:
- [ ] The gate runs first.
- [ ] `make verify` is reported as FAIL with "no Makefile / target missing".
- [ ] There's a table with one row per active AC: npm-based ACs FAIL (no tests or deps installed), and AC-7 is MANUAL with its step repeated.
- [ ] The verdict is "Not done".
- [ ] `git status` shows no changes. Nothing is installed or created, and nothing is written to GOAL.md.
