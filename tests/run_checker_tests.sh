#!/usr/bin/env bash
# Runs check_goal.sh against every fixture and checks exit code + expected message.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
check="$here/../skills/goal-miner/scripts/check_goal.sh"
pass=0; fail=0

expect() { # fixture expected_exit expected_substring
  out="$(bash "$check" "$here/fixtures/$1" 2>&1)"; code=$?
  if [ "$code" -eq "$2" ] && printf '%s' "$out" | grep -qF -- "$3"; then
    pass=$((pass+1)); echo "ok   $1"
  else
    fail=$((fail+1)); echo "FAIL $1 (exit $code, wanted $2 + \"$3\")"; printf '%s\n' "$out" | sed 's/^/     /'
  fi
}

expect good.md                  0 "OK: 6 active acceptance criteria"
expect too-many-acs.md          0 "suggest splitting into milestones"
expect missing-verified-by.md   1 'AC-2: no "verified by:" clause'
expect vague-manual.md          1 "AC-6: manual check must describe a concrete observable step"
expect unlabeled.md             1 "Non-goals: untagged item"
expect undefined-assumption.md  1 "references A-9"
expect too-few-acs.md           1 "only 3 active acceptance criteria"
expect no-verify-cmd.md         1 "exactly one fenced code block"
expect two-verify-cmds.md       1 "exactly one command line"
expect out-of-order.md          1 "sections out of order"
expect missing-section.md       1 "missing section: ## Open risks"
expect placeholder.md           1 "unresolved placeholder"
expect ../scenarios/03-amend/GOAL.md 0 "OK: 7 active acceptance criteria"
expect does-not-exist.md        2 "not found"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
