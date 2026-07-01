#!/usr/bin/env bash
# SessionStart hook for the auto-learning plugin.
# Prints the accumulated rules file to stdout so Claude Code injects it into the
# session as context. This is what keeps learned rules "always-on" without the
# plugin ever touching the user's CLAUDE.md.
#
# The rules file lives at a stable path in the user's config dir so it survives
# plugin updates and is trivial for the skill to append to and for this hook to read.

set -euo pipefail

RULES_FILE="${AUTO_LEARNING_RULES_FILE:-$HOME/.claude/auto-learning-rules.md}"

# No rules yet — nothing to inject. Exit quietly so the session starts clean.
[ -s "$RULES_FILE" ] || exit 0

echo "# Auto-learning rules (active this session)"
echo
cat "$RULES_FILE"
