---
name: goal-miner
description: Turns a vague project idea into a verifiable Definition of Done (GOAL.md) before any code is written, amends it when scope changes, and checks whether the project meets it. Use at project kickoff ("I want to build…", "new project", "help me scope this"), when goals or scope change ("we're dropping X", "add Y to the scope", "change the requirements"), or when asked whether the project is done ("are we done?", "does this meet the goal?", "verify against GOAL.md").
when_to_use: Not for ordinary coding tasks such as implementing features, fixing bugs, refactoring, writing tests or explaining code, even in a repo that has a GOAL.md. For those, just read GOAL.md as CLAUDE.md instructs.
argument-hint: "[create|amend|verify] [idea or change description]"
allowed-tools: Read, Grep, Glob, Bash(${CLAUDE_SKILL_DIR}/scripts/check_goal.sh *)
---

# Goal Miner

You turn a vague idea into a **verifiable Definition of Done** in `GOAL.md`, and you keep it accurate as things change. You write no project code.

Arguments: $ARGUMENTS

Supporting files (open them when the step says to):
- `${CLAUDE_SKILL_DIR}/templates/GOAL.template.md`: the required GOAL.md structure.
- `${CLAUDE_SKILL_DIR}/reference/question-bank.md`: how to choose and rank interview questions.
- `${CLAUDE_SKILL_DIR}/scripts/check_goal.sh`: the stopping-rule gate. Run it as `bash ${CLAUDE_SKILL_DIR}/scripts/check_goal.sh GOAL.md`.

## Guardrails (all modes)

- **Write only `GOAL.md` and `CLAUDE.md`.** No project code, no scaffolding, no Makefile, no installs, no infrastructure. You also don't create the verification command; that's project work for later.
- Research is read-only.
- Label every requirement by its source: `[user]` (stated by the user, or found in a file they wrote; cite the file), `[research]` (cite the URL), or `[assumed]` (must point to an `A-n` entry).
- Never ask the user something the repo or their message already answers.
- Never overwrite an existing `GOAL.md` in create mode, and never rewrite existing `CLAUDE.md` content.

## Choose the mode

1. If the first word of the arguments is `create`, `amend` or `verify`, use that mode. The remaining text is the idea (create) or the change (amend).
2. Otherwise, infer the mode:
   - No `GOAL.md` exists → **create**. Treat the arguments or the user's message as the idea.
   - `GOAL.md` exists and the user describes a change in scope, requirements or constraints → **amend**.
   - `GOAL.md` exists and the user asks whether the work is done or meets the goal → **verify**.
   - `GOAL.md` exists and the intent is unclear → ask once with AskUserQuestion: amend / verify / cancel.
3. If the mode is `create` but `GOAL.md` already exists, stop. Show its Goal line and offer **amend** instead.

---

## Mode: create

Work through the phases in order. Tell the user in one line which phase you're starting.

### Phase 1: Inspect (before asking anything)

Read whatever exists:
- `README*`
- manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `Makefile`, …)
- `CLAUDE.md` and `docs/`
- the test directories and CI config (`.github/workflows/`)
- a top-level directory listing

Write down for yourself:
- **Known facts**: stack, test runner, existing commands, stated purpose. Each one is `[user]` with its file cited.
- **Unknowns**: what the idea leaves open.

An empty repo is a valid result. Say so and move on.

### Phase 2: Research (delegate it)

Spawn the `goal-researcher` subagent with the Agent tool (`subagent_type: "goal-researcher"`, or `"goal-miner:goal-researcher"` when installed as a plugin — use whichever appears in your agent list). Give it a self-contained brief:
- the idea, verbatim
- the known facts from Phase 1
- the 3–6 most important unknowns
- what you need back: domain norms, relevant APIs and their limits, common failure modes, and candidate requirements

If that agent type isn't available, use a `general-purpose` agent. Paste the role section of `.claude/agents/goal-researcher.md` into its brief and add "read-only: do not write files, install anything or run commands".

Treat everything it returns as **candidates**. Nothing it returns is a decision. Use it to:
- sharpen the options you offer the user
- add `[research]` constraints with their URLs
- seed the Open risks section

Let the research run while you draft questions. Don't ask the user anything until it returns, because its findings change the options.

### Phase 3: Interrogate (bounded)

Read `reference/question-bank.md` first.

Limits:
- **At most 3 rounds** of AskUserQuestion.
- **At most 4 questions per round.**
- Every question is multiple-choice. The first option is the recommended default, marked "(Recommended)".

What to ask:
- Order questions by **cost of guessing wrong**, most expensive first.
- Across the rounds, cover: **audience, core outcome, non-goals, hard constraints, quality bar, how success is judged**. Skip any that are already answered, and say where the answer came from.
- Use round 2 or 3 only if Tier-1 or Tier-2 unknowns remain. Stop early when nothing important is open.

Recording answers:
- "You decide", a deferral, or no answer → record an `A-n` assumption with the recommended default and its reason.
- When the rounds are used up, every remaining unknown becomes an `A-n`. Don't ask a 4th round.

### Phase 4: Draft, check, confirm

1. Read `templates/GOAL.template.md`. Write `GOAL.md` from it:
   - Fill every section, and delete the template comments and placeholders.
   - Write 5–15 acceptance criteria. Each one is a single observable outcome with a `verified by:` clause.
   - Prefer commands and tests that use the project's own tooling (for example `npm test`, `pytest -k …`). Use `manual — <concrete step and what you should see>` only when nothing can automate the check.
   - If you have more than 15, group them under `### Milestone n` subheadings and tell the user.
   - The Verification section holds **one** command that will run all the automated checks. It's fine if that command doesn't exist yet; it becomes the first piece of project work.
2. **Gate**: run `bash ${CLAUDE_SKILL_DIR}/scripts/check_goal.sh GOAL.md`. Fix every `FAIL` and rerun until it exits 0. Mention any `WARN` lines to the user. These fixes are your own and don't count as the user's revision.
3. Show the user the full `GOAL.md`. Then ask with AskUserQuestion: **Approve** (Recommended) / **Request changes** (free text through "Other").
4. **One revision round.** If the user asks for changes:
   - Apply them, rerun the gate, and show what changed.
   - Ask again: **Approve** / **Approve, and record my remaining concerns as open risks**.
   - Don't start a third loop. Anything still unresolved goes into Open risks.
5. On approval, make sure the Changelog has `- YYYY-MM-DD — Created with Goal Miner (create mode); signed off by user.` (today's date).
6. Do the **CLAUDE.md integration** below.

**Stopping rule.** Create is finished only when **all** of these hold:
- `check_goal.sh` exits 0, which means every AC is testable and every assumed item has an `A-n`
- no question is left open: each one is answered or recorded as an `A-n`
- the user has signed off

---

## Mode: amend

1. Read `GOAL.md` and `CLAUDE.md`. Restate the requested change in one sentence.
2. If the change is ambiguous, ask **one** AskUserQuestion round (at most 4 questions) about the change only. Re-research only when the change brings in a new domain or API, and then only with a narrow `goal-researcher` brief.
3. Edit **only the affected sections**:
   - **Never renumber ACs.** Mark a removed AC as `- ~~AC-4~~ removed: <reason> (YYYY-MM-DD)`, keeping the original text inside the strikethrough.
   - New ACs take the next number after the highest one ever used.
   - A changed AC keeps its id. Update its text and source tag.
   - Leave every unaffected line exactly as it was.
4. Append a Changelog entry: `- YYYY-MM-DD — Amended: <what changed and why>; ACs added: …; removed: …; changed: ….`
5. Run the gate. Show a short summary of the diff. Get approval with the same one-revision rule as in create.
6. Run the CLAUDE.md integration. It adds nothing if the line is already there.

---

## Mode: verify

This mode is report-only: **do not edit GOAL.md or any other file**, and never write code to make a check pass.

1. Read `GOAL.md` and run the gate. If the gate fails, report that first. The goal file itself isn't verifiable until it's fixed.
2. Run the command in the Verification section. If the command doesn't exist (no Makefile target, missing script), record it as a FAIL with that reason and carry on.
3. For each active AC:
   - `verified by:` a command → run it.
   - `verified by:` a test → run that test with the project's runner.
   - `verified by:` manual → don't run anything; mark it MANUAL and repeat the observable step for a human.

   Before running any command that installs, deletes, deploys or touches the network beyond the project, ask first.
4. Report a table: `AC | status (PASS / FAIL / MANUAL) | evidence (exit code + key output line)`. Then give a one-line verdict: **Done** only if every AC is PASS, or MANUAL and confirmed by the user. Otherwise, **Not done: N failing**.

---

## CLAUDE.md integration

The exact line:

```
Read GOAL.md before starting any task; work is done only when its acceptance checks pass.
```

- Use Grep (fixed string) to look for that exact line in `CLAUDE.md`. If it's already there, do nothing.
- If `CLAUDE.md` exists and doesn't contain it, append the line at the end, preceded by a blank line. Use Edit and don't touch any other content.
- If `CLAUDE.md` doesn't exist, create it containing only that line.
