# auto-learning

A manual, one-shot tool that teaches Claude Code from real working sessions. When you and Claude land
on a better way of doing something, `/auto-learning` turns that lesson into a durable rule and files
it where it belongs — then keeps it active every session.

## The mental model — three layers

**1. Config = behavior, always active.**
Your `CLAUDE.md` / `AGENTS.md` and memory define *how Claude Code responds, what it says, where it
goes*. They load into every reply and work on their own, with no trigger word. This is the core —
change it carefully, through filters and confirmation.

**2. The skill = a manual recorder, one-shot.**
Not active on its own. You invoke it by hand (`/auto-learning`); it runs once per invocation. It's the
"head" / entry point — it reflects on the session and writes the conclusion down. Between invocations
it isn't in context.

**3. The skill writes INTO the config.**
Manual skill → produces a rule → the rule lands in the always-active config (including the rules file,
which a session-start hook injects each session). The bridge: manual pen → always-on memory.

You use it only in sessions where you want to improve Claude Code itself. In normal work it stays quiet.

## How always-on works without touching your CLAUDE.md

The plugin can't edit your `CLAUDE.md`, so instead it ships a **SessionStart hook**
(`scripts/load-rules.sh`) that prints your accumulated rules into every session. Rules live in a stable
file at `~/.claude/auto-learning-rules.md` — the skill appends to it, the hook reads it. That file
survives plugin updates and is never overwritten.

Override the path with the `AUTO_LEARNING_RULES_FILE` environment variable if you prefer a different
location.

## Install

Once it's approved in the community marketplace:

```
/plugin marketplace add anthropics/claude-plugins-community
/plugin install auto-learning@claude-community
/reload-plugins
```

Try it right now, before it's published, by pointing Claude Code at a local clone:

```
claude --plugin-dir /path/to/auto-learning
```

## Use

- `/auto-learning` — reflect on the current session and propose rules to keep (Mode A).
- `/auto-learning prune` — review and clean up accumulated rules (Mode B).

The skill is **user-only** (`disable-model-invocation`): it never fires on its own, because it writes
to your config. You decide when to run it.

## What it contains

- `skills/auto-learning/` — the reflection loop (`SKILL.md`) and its method references (`reference/`).
- `hooks/hooks.json` + `scripts/load-rules.sh` — the SessionStart hook that keeps rules always-on.

## License

MIT — see `LICENSE`.
