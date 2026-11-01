# GOAL: readlist

## Goal

A personal command-line tool that lets one person track books they want to read, are reading, and have finished. [user]

## Definition of Done

- [ ] **AC-1** [user] `rl add "Dune"` stores a book and `rl list` shows it — verified by: `npm test -- add.test.js`
- [ ] **AC-2** [user] Books move between want/reading/done states — verified by: test test/state.test.js
- [ ] **AC-3** [research] Data file survives a crash mid-write (atomic rename) (source: https://example.com/atomic-writes) — verified by: test test/atomic.test.js
- [ ] **AC-4** [assumed] Data lives in `~/.readlist.json` (A-1) — verified by: `npm test -- storage.test.js`
- [ ] **AC-5** [user] `rl --help` documents every command — verified by: `npm test -- help.test.js`
- [ ] **AC-6** [user] First-run experience is clear — verified by: manual — run `rl` with no data file; see a one-line hint to use `rl add`
- ~~AC-7 [user] Export to CSV — verified by: `npm test -- export.test.js`~~ removed: dropped from scope (2026-10-31)

## Non-goals

- [user] No sync between devices.
- [assumed] No Windows support in v1 (A-2).

## Constraints

- [user] Node 20+, no native dependencies (package.json).

## Assumptions

- **A-1** Single JSON file in the home directory — reason: user said "you decide".
- **A-2** macOS and Linux only — reason: not answered within 3 rounds.

## Verification

```sh
npm test
```

## Changelog

- 2026-10-30 — Created with Goal Miner (create mode); signed off by user.
- 2026-10-31 — Amended: dropped CSV export; removed: AC-7.
