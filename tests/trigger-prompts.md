# Trigger tests (manual)

Run each prompt in a **fresh** `claude` session started in a scenario copy:
- Use `tests/scenarios/setup.sh 02-partial-docs` for most prompts.
- Use `03-amend` for the prompts marked †, which need an existing GOAL.md.

Record whether the `Skill` tool fired with `goal-miner`. Don't name the skill in any prompt.

Target: every should-trigger prompt fires, and at most 1 should-not-trigger prompt fires. If the results miss that target, adjust `description` / `when_to_use` in SKILL.md once and rerun the whole list.

## Should trigger

| # | Prompt | Expected mode | Fired? |
|---|---|---|---|
| T1 | I want to build a tool that checks broken links across our whole docs site. Help me scope it before we start. | create | |
| T2 | New project: a Slack bot that summarises standups. Where do we start? | create | |
| T3 | Help me figure out what "done" looks like for this project. | create | |
| T4 † | We're dropping the CSV export feature and adding sync between laptops. | amend | |
| T5 † | Change of plans: this needs to work on Windows too. | amend | |
| T6 † | Are we done? Does this meet the goal? | verify | |
| T7 † | Verify the project against GOAL.md. | verify | |
| T8 | Before writing any code, I want clear acceptance criteria for this idea: a CLI that tracks my reading list. | create | |

## Should NOT trigger

| # | Prompt | Fired? |
|---|---|---|
| N1 | Add a `--json` output flag to the CLI. | |
| N2 | This test is failing, can you fix it? | |
| N3 | Refactor `brokenLinks` to be async. | |
| N4 † | What does GOAL.md say about storage? | |
| N5 | Write a test for `findRelativeLinks` with anchors only. | |
| N6 | Explain how the regex in cli.js works. | |
| N7 † | Implement AC-2 from GOAL.md. | |
| N8 | Bump jest to the latest version. | |
