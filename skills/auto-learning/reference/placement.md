# Placing a rule — which config tier

> Method reference for the auto-learning skill: where a derived rule should live, plus anti-duplication.

## Tiers (where an accepted rule can land)

| Tier | What goes there | Signal |
|---|---|---|
| **Always-on instructions** (`CLAUDE.md` / `AGENTS.md`) | cross-cutting behavior applied in EVERY reply | "acts on its own, no trigger word" |
| **The rules file** (`~/.claude/auto-learning-rules.md`) | a narrow collaboration nuance from one episode | the skill's default |
| **Memory / persistent notes** (if your setup has them) | a contextual fact/guidance that surfaces by topic | "needed sometimes, when the topic comes up" |
| **Settings / hooks** | a permission, an automated reaction to an event | "automation on an event, not behavior text" |
| **An agent / subagent** | behavior of a pipeline agent | "a role in a pipeline, not a manual procedure" |
| **Another skill** | a manual, multi-step procedure invoked on demand | "loads only when explicitly invoked" |

## The "always-on vs on-invocation" test

Always-on behavior (fires by context on its own) → belongs in your always-on instructions, or in a
mechanism that loads every session (like this plugin's rules file + hook).
It does **not** belong inside a skill: a skill loads only when explicitly invoked.

## Anti-duplication (strict)

Before writing, survey the whole landscape (always-on instructions, memory, other skills, the rules
file). Overlaps something existing → **update that**, don't place a parallel copy next to it. A rule
lives in ONE place: move it, don't copy it.

## Delegating the big stuff

auto-learning decides **what** and **where**, and makes the targeted edit. Hand off large or risky
work: multi-file changes and settings/hooks edits go through your normal review and config-editing
process, not this one-shot loop.
