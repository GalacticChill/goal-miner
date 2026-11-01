# GOAL: {{project name}}

<!--
Goal Miner template. Rules (enforced by scripts/check_goal.sh):
- Keep the eight "## " sections below, in this order, each exactly once.
- Source tags: every AC, Non-goal and Constraint carries [user], [research] or [assumed].
  [user]     = the user said it, or it comes from a file the user wrote (cite it: "(README)").
  [research] = came from research; cite the source URL.
  [assumed]  = nobody decided; must reference an A-n entry, e.g. "(A-2)".
- Every AC has "verified by:" + one of:
    `shell command`            e.g. verified by: `npm test -- export.test.js`
    test <path or name>        e.g. verified by: test tests/test_sync.py::test_conflict
    manual — <observable step> e.g. verified by: manual — run `rl add "Dune"`; `rl list` shows "Dune"
  Prefer commands. Keep manual checks to at most a third of the ACs.
- 5–15 active ACs. More than 15: group them under "### Milestone n" subheadings in Definition of Done.
- Amend mode never renumbers: strike a removed AC as "- ~~AC-4~~ removed: <reason> (YYYY-MM-DD)"
  and give new ACs the next free number.
- Replace every {{placeholder}} and delete these HTML comments before sign-off.
-->

## Goal

{{One or two sentences: who it is for, and what they can do when it is finished.}} [user]

## Definition of Done

- [ ] **AC-1** [user] {{observable outcome}} — verified by: `{{command}}`
- [ ] **AC-2** [research] {{outcome}} (source: {{url}}) — verified by: test {{path::name}}
- [ ] **AC-3** [assumed] {{outcome}} (A-1) — verified by: manual — {{concrete step and what you should see}}

## Non-goals

- [user] {{explicitly out of scope}}

## Constraints

- [user] {{hard constraint: language, platform, budget, deadline, licence, data rules}}
- [research] {{limit found in research}} (source: {{url}})

## Assumptions

- **A-1** {{what was assumed}} — reason: {{why: "user said 'you decide'", "no answer after 3 rounds", or a researched default}}

## Open risks

- {{risk, plus what would trigger revisiting the goal}}

## Verification

```sh
{{single command that runs every automated AC, e.g. make verify}}
```

## Changelog

- {{YYYY-MM-DD}} — Created with Goal Miner (create mode); signed off by user.
