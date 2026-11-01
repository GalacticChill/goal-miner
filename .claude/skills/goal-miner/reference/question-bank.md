# Goal Miner question bank

Use this to pick interview questions. **Skip any question the repo, the user's arguments, or an earlier answer already settles.** Rank what is left by *cost of guessing wrong*: how much work gets thrown away if the guess turns out wrong. Ask the most expensive unknowns first.

Each AskUserQuestion question has 2–4 concrete options. The first option is the recommended default, labelled "(Recommended)", with a one-line reason in its description. Write options from what the repo and the research found, not from generic lists.

## Tier 1: ask first (a wrong guess changes the whole design)

| Topic | Question shape | Typical options to tailor |
|---|---|---|
| Audience | "Who will use this first?" | just me / my team (internal) / public users / another program (API consumers) |
| Core outcome | "When this is done, what can the user do that they can't do today?" | 2–3 concrete outcomes taken from the idea, plus a narrower MVP option |
| Hard constraints | "Which of these are fixed?" (multiSelect) | language or stack already in the repo / must run offline / budget or free tier only / deadline / data must stay local |
| Form factor | "What shape should it take?" | CLI / web app / library / service. Only ask if the idea and the repo don't settle it. |

## Tier 2: ask next (a wrong guess changes the scope)

| Topic | Question shape | Typical options |
|---|---|---|
| Non-goals | "Which of these are explicitly out of scope for v1?" (multiSelect) | the 3–4 most tempting extensions found in research (auth, sync, mobile, admin UI…) |
| Quality bar | "What quality bar is 'done'?" | personal prototype (happy path only) / internal tool (tests on core paths) / production (tests + error handling + docs) |
| Success judgement | "How will you decide it worked?" | an automated test suite passes / a specific demo works / a metric threshold / someone else signs off |

## Tier 3: ask only if rounds remain (a wrong guess is cheap to fix later)

- Data volume and performance targets, if research found real limits (API rate limits, file sizes).
- Platforms and OS support.
- Distribution: a package registry, a binary, or a deploy target.
- Accessibility or localisation needs, for user-facing UIs.

## Handling answers

- **"You decide", or an "Other" answer that defers:** record it as `A-n` with the recommended option and `reason: user said "you decide"`. Tag any requirement that depends on it `[assumed] (A-n)`.
- **No answer after round 3:** record the recommended default as `A-n` with `reason: not answered within 3 rounds`.
- **An answer contradicts the research:** keep the user's choice. Add the research point to Open risks.
- **An answer contradicts a repo fact** (for example, "use Python" in a TypeScript repo): ask once in the next round. Don't silently pick one.
