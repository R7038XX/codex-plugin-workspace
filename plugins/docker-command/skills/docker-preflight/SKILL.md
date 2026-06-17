---
name: docker-preflight
description: >-
  Use when checking whether Docker and Docker Compose are available before
  Docker-backed work, classifying daemon or socket failures, checking current
  Docker context, disk usage, and scanner availability. Do not use for cleanup
  or compose smoke tests.
---

## When to use

Use for Docker availability checks, daemon/socket failure classification,
context checks, disk usage checks, and scanner availability checks before
Docker-backed work.

## Workflow

1. Run `scripts/docker-preflight.sh`.
2. Treat its JSON output as the current Docker state for this turn.
3. Reuse the result instead of rerunning the same status commands unless the
   Docker state changed.
4. Read `references/common-failures.md` only when a failure needs classification.
5. Read `references/docker-command-basics.md` only when command meaning or
   safety is unclear.

## References

- `references/common-failures.md`
- `references/docker-command-basics.md`

## Scripts

- `scripts/docker-preflight.sh`

## Output handling

Use `summary`, `warnings`, `failures`, and `checks[]` from JSON output.
Do not paste raw Docker output unless needed.

## Safety rules

- Do not run cleanup or compose smoke tests from this Skill.
