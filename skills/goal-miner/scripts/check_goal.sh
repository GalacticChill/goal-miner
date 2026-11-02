#!/usr/bin/env bash
# check_goal.sh — structural lint for GOAL.md (the Goal Miner stopping rule).
# Usage: check_goal.sh [path/to/GOAL.md]   (default: ./GOAL.md)
# Exit 0 = passes (warnings allowed), 1 = one or more FAIL lines, 2 = file missing.
# Portable: bash + POSIX/BSD awk only.
set -u
f="${1:-GOAL.md}"
[ -f "$f" ] || { echo "FAIL: $f not found"; exit 2; }

awk '
function fail(m) { print "FAIL: " m; nfail++ }
function warn(m) { print "WARN: " m; nwarn++ }
function tagged(s) { return s ~ /\[(user|research|assumed)\]/ }
function lc(s) { return tolower(s) }
# Collect every A-n reference in s (not preceded by a letter, so AC-n is ignored).
function collect_refs(s, where,   t, r) {
  t = " " s; found = 0
  while (match(t, /[^A-Za-z]A-[0-9]+/)) {
    r = substr(t, RSTART + 1, RLENGTH - 1)
    refs[r] = refs[r] ? refs[r] : where
    found++
    t = substr(t, RSTART + RLENGTH)
  }
  return found
}
BEGIN {
  nwant = split("Goal|Definition of Done|Non-goals|Constraints|Assumptions|Open risks|Verification|Changelog", want, "|")
  sec = ""; nb = 0; open = 0; nh = 0; vfences = 0; vcmd = 0; infence = 0
}
# Leftover template placeholders anywhere.
/\{\{|TBD|\?\?\?/ { fail("line " NR ": unresolved placeholder (TBD / {{...}} / ???): " $0) }
/goal-miner: allow-few-acs/ { allowfew = 1 }
# Fenced code blocks.
/^[ \t]*```/ {
  infence = !infence
  if (sec == "Verification" && infence) vfences++
  open = 0
  next
}
infence {
  if (sec == "Verification" && vfences == 1 && $0 !~ /^[ \t]*(#.*)?$/) vcmd++
  next
}
# Level-2 headings delimit sections (### subheadings such as milestones stay inside).
/^## / {
  h = substr($0, 4); sub(/[ \t]+$/, "", h)
  heads[++nh] = h; sec = h; open = 0
  next
}
# Top-level bullets start a block; indented lines continue the open block.
/^[-*] / { nb++; bsec[nb] = sec; btxt[nb] = $0; open = 1; next }
/^[ \t]+[^ \t]/ { if (open) btxt[nb] = btxt[nb] " " $0; next }
/^[ \t]*$/ { open = 0; next }
{ open = 0 }

END {
  # 1. Required sections, each once, in order.
  k = 0
  for (i = 1; i <= nh; i++) {
    for (j = 1; j <= nwant; j++) if (heads[i] == want[j]) { cnt[j]++; got[++k] = j }
  }
  for (j = 1; j <= nwant; j++) {
    if (!cnt[j]) fail("missing section: ## " want[j])
    else if (cnt[j] > 1) fail("duplicate section: ## " want[j])
  }
  for (i = 2; i <= k; i++) if (got[i] < got[i-1]) { fail("sections out of order: \"" want[got[i]] "\" appears after \"" want[got[i-1]] "\""); break }

  # 2. Walk bullet blocks by section.
  active = 0; manual = 0; nchange = 0
  for (b = 1; b <= nb; b++) {
    s = btxt[b]; S = bsec[b]
    if (S == "Definition of Done" && match(s, /AC-[0-9]+/)) {
      id = substr(s, RSTART, RLENGTH)
      if (id in acs) fail(id ": duplicate AC id")
      acs[id] = 1
      if (s ~ /~~[^~]*AC-[0-9]+[^~]*~~/) continue   # struck-through = removed in an amend
      active++
      if (!tagged(s)) fail(id ": missing source tag [user]/[research]/[assumed]")
      p = index(lc(s), "verified by:")
      if (!p) { fail(id ": no \"verified by:\" clause"); }
      else {
        v = substr(s, p + 12); gsub(/^[ \t`]+|[ \t`.]+$/, "", v)
        if (v == "" || lc(v) ~ /^(n\/a|none|-)$/) fail(id ": empty \"verified by:\" clause")
        else if (lc(v) ~ /^manual/) {
          manual++
          w = v; sub(/^[Mm]anual[ \t]*(—|–|-|:)?[ \t]*/, "", w)
          if (length(w) < 10) fail(id ": manual check must describe a concrete observable step")
        }
      }
      if (s ~ /\[assumed\]/ && !collect_refs(s, id)) fail(id ": [assumed] but no A-n reference")
      else collect_refs(s, id)
    }
    else if (S == "Non-goals" || S == "Constraints") {
      if (lc(s) ~ /^[-*] *(none|n\/a)\.? *$/) continue
      short = substr(s, 1, 60)
      if (!tagged(s)) fail(S ": untagged item: " short)
      if (s ~ /\[assumed\]/ && !collect_refs(s, S)) fail(S ": [assumed] item has no A-n reference: " short)
    }
    else if (S == "Assumptions" && match(s, /A-[0-9]+/)) {
      id = substr(s, RSTART, RLENGTH)
      if (id in defined) fail(id ": duplicate assumption id")
      defined[id] = 1
      if (lc(s) !~ /reason:/) fail(id ": assumption has no \"reason:\"")
    }
    else if (S == "Changelog") nchange++
  }

  # 3. Every referenced A-n must exist.
  for (r in refs) if (!(r in defined)) fail(refs[r] ": references " r ", which is not defined under ## Assumptions")

  # 4. AC count and balance.
  if (active < 5 && !allowfew) fail("only " active " active acceptance criteria (need 5-15, or add <!-- goal-miner: allow-few-acs --> if the user agreed)")
  if (active > 15) warn(active " acceptance criteria (>15): suggest splitting into milestones")
  if (active > 0 && manual * 3 > active) warn(manual " of " active " ACs are manual checks (aim for <= 1/3)")

  # 5. Verification: exactly one fenced block with exactly one command line.
  if (vfences != 1) fail("## Verification must contain exactly one fenced code block (found " vfences ")")
  else if (vcmd != 1) fail("## Verification block must contain exactly one command line (found " vcmd ")")

  # 6. Changelog has at least one entry.
  if (cnt[8] && nchange < 1) fail("## Changelog has no entries")

  if (nfail) { print nfail " problem(s) found."; exit 1 }
  print "OK: " active " active acceptance criteria" (manual ? " (" manual " manual)" : "") (nwarn ? ", " nwarn " warning(s)" : "") "."
}
' "$f"
