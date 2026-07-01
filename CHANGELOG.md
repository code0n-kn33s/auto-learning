# Changelog

All notable changes to this plugin are documented here. This project follows
[Semantic Versioning](https://semver.org): bump MAJOR for breaking changes,
MINOR for new features, PATCH for fixes. Bump `version` in `.claude-plugin/plugin.json`
on every release so installed users receive the update.

## [1.0.0] - 2026-07-01

Initial release.

### Added
- `/auto-learning` skill — a manual, one-shot reflection loop that turns lessons
  from a session into durable rules (observe → filter → place → confirm → record).
- Quality filters: *principle-not-symptom* and *cold-read*, so rules stay general
  and readable without session context.
- Config-tier placement (always-on instructions vs. the accumulated rules file).
- Pruning mode to review and remove stale or contradicted rules.
- SessionStart hook (`scripts/load-rules.sh`) that injects accumulated rules into
  every session, keeping them always-on without editing the user's CLAUDE.md.
- `disable-model-invocation`: the skill is user-only and never auto-fires, because
  it writes to config.
- Method references: `reference/vision-width.md`, `reference/placement.md`.
