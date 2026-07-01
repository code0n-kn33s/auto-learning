---
name: auto-learning
description: >
  Turn lessons from a working session into durable rules for Claude Code. A manual, one-shot
  reflection loop: derive a rule or recommendation from what actually happened, filter it for
  quality, decide which config file it belongs in (CLAUDE.md / AGENTS.md, memory, the always-on
  rules file, or another config), and record it. A second mode prunes accumulated rules. Invoke
  it only when you deliberately want to improve how Claude Code behaves — it writes to config,
  so it never auto-triggers.
disable-model-invocation: true
---

# What this is

A **manual tool for teaching Claude Code from real experience.** You invoke it explicitly; it runs
once per invocation and is not present between invocations (see `README.md` for the mental model).

Its domain is your **Claude Code configuration surface**: `CLAUDE.md` / `AGENTS.md`, memory,
other skills — and itself. Its single responsibility is the loop **observe → filter → place →
confirm → record**. Two ways into the loop:
- **(a) from the session** (default) — notice where you and the user landed on something better,
  and propose to lock it in;
- **(b) a direct request** — "improve this config / this skill" → the same quality gate and
  placement step, without scanning the session.

It does **not** perform large, multi-file config surgery itself — it decides **what** to record and
**where**, and makes the targeted edit. Hand heavy or risky multi-file work to your normal review
process.

Learned rules are stored in `~/.claude/auto-learning-rules.md`. The plugin's SessionStart hook
prints that file into every session, so the rules stay active **all the time** — the bridge from
"manual pen" to "always-on memory." (This is why the rules live in a stable file, not inside the
skill: a skill only loads when invoked.)

Honesty principle: **no real episode or basis → no rule.** Never invent one.

## ⚠️ Survey the whole configuration first (required before any proposal)

A config-level change can't be judged from one file. Before proposing, survey the **whole
landscape** so the new rule neither duplicates nor contradicts what already exists:
- your always-on instructions — `CLAUDE.md` / `AGENTS.md`
- memory / persistent notes, if your setup has them
- other skills and their triggers — `~/.claude/skills/`
- the existing rules file — `~/.claude/auto-learning-rules.md`

Placement and anti-duplication logic lives in `reference/placement.md`. If a proposal overlaps
something that exists → don't add a parallel copy: either **update** the existing rule/file (and say
which), or drop the proposal.

# Invocation and mode

This skill is **user-only** (`disable-model-invocation`): it runs only when the user types
`/auto-learning`. There is no phrase-based auto-trigger, because it writes to config and must be
deliberate. If the user describes a pattern worth keeping but hasn't invoked the skill, **remind
them to run `/auto-learning`** rather than invoking it yourself.

Mode is chosen by argument/context:
- default / "propose something new" → **Mode A** (propose new)
- "prune" / "clean up" / "what's in the rules file" → **Mode B** (pruning)
- If in Mode A the rules file has grown large (≳12 lines), offer pruning at the end.

---

# Mode A — propose new (default)

**Two entry points:**
- **(a) from the session** (default) — start at Step 1.
- **(b) a direct request** ("improve config X / this skill") — **skip Step 1** (no need to scan the
  session, the user already gave the basis), start at Step 2: formulation + the two filters. Then
  Step 3.5 (where) and Step 3 (confirm) as usual.

## Step 1. Walk the current session

Look ONLY for real episodes from this conversation (verify before asserting — not from memory):
- **"was X → became better"** — the user corrected a format/approach and the new one clearly landed
- **friction** — the user pushed back, re-asked, or you had to redo something
- **what clearly worked** — the user confirmed "yes, like that / exactly right"

Not an episode (skip): a one-off edit with no generalization, your guess that "they'd probably like
it," anything already covered by existing config (check — don't duplicate).

## Step 2. Form proposals

**At most 1–3 per invocation.** If nothing is worth it, say so honestly — "nothing to propose, no
stable pattern this session" — and stop. Don't force it.

Each proposal uses a fixed format:

```
📌 Observation: <what concretely happened in the session>
💡 Proposing: <the rule or recommendation, stated>
🏷 Type: rule (mechanic "if X → Y") | recommendation (principle: when and why)
```

Type distinction:
- **rule** = hard mechanic `if [trigger] → [action]`, no "suggest/seems"
- **recommendation** = principle/context: when and why, no rigid trigger

**Two filters before locking a formulation (criteria, not wishes):**
1. **Principle, not symptom** — step back: is this the general principle or one narrow case? Lock in
   the principle; the specific occasion is at most an example inside the wording. (Failure example:
   "check for a native equivalent" — a narrow symptom of the broader principle "widen your view
   during planning.")
2. **Cold-read** — the wording must read "cold": understandable to a reader with no session context.
   Mentally run "would I get this from scratch?" Fails → rewrite, don't propose.

**The principle behind the filters — "field of view matches the phase"** (method: `reference/vision-width.md`):
the first formulation is almost always "floating" — that's normal, not failure. The remedy is to zoom
out: step back, take in the whole picture of the topic, and reformulate from scratch until it's
precise and self-contained. Not word-tweaking — a fresh pass.

## Step 3. Confirm each one

Ask the user (one at a time or batched): **Accept / Revise / Reject.**
Silence ≠ consent — write only on an explicit "Accept."
"Revise" → the user gives their wording, and that is what goes in.
The user didn't understand the wording → that's a cold-read failure (Step 2), not a small tweak:
rewrite from scratch, don't twiddle a word.

## Step 3.5. Decide the level — which config to target

The rules file is **not the only home.** Before writing, choose the tier by the rule's reach (full
logic in `reference/placement.md`). Briefly:
- **always-on instructions** (`CLAUDE.md` / `AGENTS.md`) — a principle that applies in EVERY reply /
  baseline behavior. Add it next to its kin; generalize existing text, don't create a parallel copy.
- **memory** (if your setup has it) — contextual guidance that surfaces by topic.
- **another config** (another skill, a settings/hook file, an agent) — if the rule belongs there by
  nature. Hand large or validated changes to your normal review process.
- **the rules file** `~/.claude/auto-learning-rules.md` — a narrow collaboration nuance from a single
  episode (the skill's default).

If the tier isn't obvious, or the rule is broader than a nuance, offer the choice to the user rather
than dumping it into the rules file by default. Wherever it lands, the rule lives in **one** place:
move it, don't copy it (anti-duplication).

## Step 4. Record what was accepted

Tier = rules file → append to `~/.claude/auto-learning-rules.md` with **Edit** (append, don't
overwrite). Line format:

```
- [YYYY-MM-DD] **rule|recommendation**: <wording>
```

Use today's real date. No grouping needed — a flat list; pruning handles growth.
Tier = another config → write by that file's conventions (a bullet in CLAUDE.md, a memory note, etc.).

---

# Mode B — pruning

## Step 1. Show current
Read `~/.claude/auto-learning-rules.md`, list the rules with dates and types.

## Step 2. Propose removal candidates
- rules that recent sessions **contradicted** (the user did otherwise)
- duplicates / rules absorbed by another
- too-narrow rules that fired once and are no longer relevant

If there are no candidates, say "all current, nothing to clean."

## Step 3. Remove on confirmation
Confirm each candidate with the user → delete the line with **Edit**.
If the file ends up empty, leave it empty (the hook simply injects nothing).

---

# Wrap-up (both modes)

1. **Self-check before reporting:** cold-read what you wrote — did it land precisely in the target
   file, does it read without session context, did it avoid duplicating something existing? If not,
   fix it immediately.
2. One-line report: how many added/removed and where (file path).
3. This changed config → remind the user to back it up however they version their dotfiles.
