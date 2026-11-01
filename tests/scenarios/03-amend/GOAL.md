# GOAL: readlist

## Goal

A personal command-line tool that lets one person track books they want to read, are reading, and have finished. [user]

## Definition of Done

- [ ] **AC-1** [user] `rl add "Dune"` stores a book and `rl list` shows it — verified by: `npm test -- add.test.js`
- [ ] **AC-2** [user] Books move between want/reading/done with `rl start` and `rl finish` — verified by: test test/state.test.js
- [ ] **AC-3** [research] The data file survives a crash mid-write via write-then-rename (source: https://lwn.net/Articles/457667/) — verified by: test test/atomic.test.js
- [ ] **AC-4** [assumed] Data lives in `~/.readlist.json` (A-1) — verified by: `npm test -- storage.test.js`
- [ ] **AC-5** [user] `rl export --csv` writes a CSV with title, author, status, finished date — verified by: `npm test -- export.test.js`
- [ ] **AC-6** [user] `rl --help` documents every command — verified by: `npm test -- help.test.js`
- [ ] **AC-7** [user] First run is self-explanatory — verified by: manual — run `rl` with no data file; see a one-line hint suggesting `rl add`

## Non-goals

- [user] No web or mobile UI.
- [assumed] No Windows support in v1 (A-2).

## Constraints

- [user] Node 20+, CommonJS, no native dependencies (CLAUDE.md).
- [research] CSV output must quote fields containing commas or quotes per RFC 4180 (source: https://www.rfc-editor.org/rfc/rfc4180).

## Assumptions

- **A-1** Single JSON file in the home directory — reason: user said "you decide".
- **A-2** macOS and Linux only — reason: not answered within 3 rounds.

## Open risks

- JSON storage may slow down past ~5k books; revisit if that happens.

## Verification

```sh
make verify
```

## Changelog

- 2026-10-30 — Created with Goal Miner (create mode); signed off by user.
