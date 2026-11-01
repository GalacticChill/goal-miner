#!/usr/bin/env bash
# Copy a scenario seed plus the Goal Miner skill/agent into a fresh git repo for a dry run.
# Usage: tests/scenarios/setup.sh <01-empty|02-partial-docs|03-amend> [target-dir]
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
root="$here/../.."
name="${1:?scenario name required}"
target="${2:-${TMPDIR:-/tmp}/goal-miner-$name}"
[ -d "$here/$name" ] || { echo "no such scenario: $name"; exit 1; }
rm -rf "$target"; mkdir -p "$target/.claude"
cp -R "$here/$name/." "$target/"
cp -R "$root/.claude/skills" "$root/.claude/agents" "$target/.claude/"
cd "$target"
git init -q && git add -A && git commit -qm "scenario seed: $name"
echo "Ready: $target"
echo "Next:  cd $target && claude"
echo "After: git status && git diff   # inspect exactly what Goal Miner changed"
