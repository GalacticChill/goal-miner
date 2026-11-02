# Goal Miner

Goal Miner is a Claude Code skill for people who start projects with a vague idea and want Claude to build the right thing. Before any code is written, it inspects your repo, researches the domain, and asks you a short, bounded set of multiple-choice questions. From that it writes `GOAL.md`: a Definition of Done in which every acceptance criterion can be checked with a command, a test, or a concrete manual step. Later it keeps `GOAL.md` current when the scope changes, and it can check the project against it.

## Install

### As a plugin (recommended)

In Claude Code:

```
/plugin marketplace add GalacticChill/goal-miner
/plugin install goal-miner@goal-miner
```

### From source

```sh
git clone https://github.com/GalacticChill/goal-miner
cd goal-miner
```

User level (available in all your projects):

```sh
mkdir -p ~/.claude/skills ~/.claude/agents
ln -s "$PWD/skills/goal-miner"           ~/.claude/skills/goal-miner
ln -s "$PWD/agents/goal-researcher.md"   ~/.claude/agents/goal-researcher.md
```

Single project only:

```sh
mkdir -p /path/to/project/.claude/skills /path/to/project/.claude/agents
cp -R skills/goal-miner          /path/to/project/.claude/skills/
cp agents/goal-researcher.md     /path/to/project/.claude/agents/
```

Start a new Claude Code session after installing.

## Typical workflow

1. **Mine the goal.** Run `/goal-miner <your idea>`, answer at most 3 rounds of questions, and sign off on `GOAL.md`.
2. **Plan from GOAL.md.** Ask Claude for an implementation plan based on the acceptance criteria.
3. **Build the verification command first**, e.g. `make verify`, so that "done" can be checked from day one.
4. **Work in milestones**, each one aimed at a group of acceptance criteria.
5. **Check progress** with `/goal-miner verify`.
6. **When the scope changes**, run `/goal-miner amend <what changed>`.

## Modes

| Mode | Invoke | What happens |
|---|---|---|
| **create** (default) | `/goal-miner <idea>`, or just say *"I want to build… help me scope it"* | Runs in four phases: inspect the repo, research (read-only subagent), a bounded interview (at most 3 rounds of at most 4 multiple-choice questions), then draft, revise once and sign off. Writes `GOAL.md` and adds one line to `CLAUDE.md`. |
| **amend** | `/goal-miner amend <what changed>`, or *"we're dropping X and adding Y"* | Edits only the affected sections. AC ids are never renumbered: removed ACs are struck through and new ones get the next number. Appends a Changelog entry. |
| **verify** | `/goal-miner verify`, or *"are we done?"* | Runs the Verification command and each AC's check, then reports PASS / FAIL / MANUAL per AC. **Report only: it never edits files.** |

If `GOAL.md` already exists, `create` refuses to overwrite it and offers `amend` instead.

## What GOAL.md looks like

Eight sections, always in this order:
1. Goal
2. Definition of Done (`AC-n`, each with `verified by: …`)
3. Non-goals
4. Constraints
5. Assumptions (`A-n` with a reason)
6. Open risks
7. Verification (one command)
8. Changelog

Every AC, non-goal and constraint is tagged with where it came from:
- `[user]`: the user said it, or it's in a file they wrote
- `[research]`: found in research, with a URL
- `[assumed]`: nobody decided it, so it points to an `A-n` entry

See `skills/goal-miner/templates/GOAL.template.md`.

## The stopping rule and its checker

The skill can't finish until `check_goal.sh` passes. The checker uses only bash and awk, with no dependencies. It fails when:
- any AC lacks a non-empty `verified by:` clause, or a manual check lacks a concrete step
- any AC, non-goal or constraint is untagged, or `[assumed]` points to no `A-n`, or to one that isn't defined
- there are fewer than 5 active ACs (it only warns above 15 and suggests milestones)
- the Verification section doesn't hold exactly one command
- sections are missing or out of order, or placeholders such as `{{…}}`, `TBD` or `???` are left in

You can run it yourself at any time:

```sh
bash skills/goal-miner/scripts/check_goal.sh GOAL.md
```

**Expect `verify` to fail on a new project.** The Verification command is named in GOAL.md but not created, because Goal Miner writes no project code. Building it is the first task.

## Files

```
.claude-plugin/plugin.json                 plugin manifest
.claude-plugin/marketplace.json            single-plugin marketplace, for /plugin marketplace add
skills/goal-miner/SKILL.md                 procedure, mode routing, guardrails
skills/goal-miner/templates/               GOAL.md template
skills/goal-miner/reference/               interview questions ranked by cost of guessing wrong
skills/goal-miner/scripts/check_goal.sh    stopping-rule checker
agents/goal-researcher.md                  read-only research subagent (Read/Grep/Glob/WebSearch/WebFetch)
.claude/                                   symlinks so the skill also works when you run claude inside this repo
tests/                                     checker fixtures, trigger prompts, dry-run scenarios
```

## Testing

```sh
bash tests/run_checker_tests.sh        # automated: checker against fixtures
tests/scenarios/setup.sh 01-empty      # then follow tests/scenarios/README.md
```

Trigger and scenario tests are manual (see `tests/trigger-prompts.md` and `tests/scenarios/README.md`), because the interview needs a human to answer it.

## License

MIT. See [LICENSE](LICENSE).
