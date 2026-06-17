---
name: docker-cleanup-safe
description: >-
  Use after Docker-backed work to run non-destructive cleanup, inspect usage before
  and after cleanup, and prepare dry-run cleanup plans.
---

## When to use

Use after Docker-backed work to run non-destructive cleanup or report cleanup plans.

## Workflow

1. Run `./scripts/docker-cleanup-safe.sh --dry-run` before real cleanup.
2. When scoped cleanup is needed, pass `--scoped` with `CLEANUP_SCOPE_LABEL`
   or `COMPOSE_PROJECT_NAME`.
3. Prefer default mode only when AGENTS.md or user permits non-destructive cleanup.

## References

- `references/cleanup-policy.md`

## Scripts

- `scripts/docker-cleanup-safe.sh`

## Output handling

Use JSON `status`, `summary`, `commands`, `warnings`, and `failures`.
Report before/after `docker system df` values.

## Safety rules

- Never run `docker system prune -a`, `docker system prune -a --volumes`, `docker volume prune`, or `docker builder prune -a`.
