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
- [ ] **AC-8** [user] Extra criterion 8 — verified by: `npm test -- extra8.test.js`
- [ ] **AC-9** [user] Extra criterion 9 — verified by: `npm test -- extra9.test.js`
- [ ] **AC-10** [user] Extra criterion 10 — verified by: `npm test -- extra10.test.js`
- [ ] **AC-11** [user] Extra criterion 11 — verified by: `npm test -- extra11.test.js`
- [ ] **AC-12** [user] Extra criterion 12 — verified by: `npm test -- extra12.test.js`
- [ ] **AC-13** [user] Extra criterion 13 — verified by: `npm test -- extra13.test.js`
- [ ] **AC-14** [user] Extra criterion 14 — verified by: `npm test -- extra14.test.js`
- [ ] **AC-15** [user] Extra criterion 15 — verified by: `npm test -- extra15.test.js`
- [ ] **AC-16** [user] Extra criterion 16 — verified by: `npm test -- extra16.test.js`
- [ ] **AC-17** [user] Extra criterion 17 — verified by: `npm test -- extra17.test.js`

## Non-goals

- [user] No sync between devices.
- [assumed] No Windows support in v1 (A-2).

## Constraints

- [user] Node 20+, no native dependencies (package.json).

## Assumptions

- **A-1** Single JSON file in the home directory — reason: user said "you decide".
- **A-2** macOS and Linux only — reason: not answered within 3 rounds.

## Open risks

- JSON file may grow slowly with thousands of books; revisit if over 5k entries.

## Verification

```sh
npm test
```

## Changelog

- 2026-10-30 — Created with Goal Miner (create mode); signed off by user.
- 2026-10-31 — Amended: dropped CSV export; removed: AC-7.
