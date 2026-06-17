---
name: docker-verify
description: >-
  Use when running Docker Compose build, test service execution, service startup,
  compose ps, or container-internal smoke checks after preflight.
---

## When to use

Use for Docker Compose build, test service execution, service startup,
`compose ps`, and container-internal smoke checks after preflight.

## Workflow

1. Confirm preflight passed.
2. Collect repo-specific `APP_SERVICE`, `TEST_SERVICE`, `HEALTH_COMMAND`, and optional `TEST_COMMAND`.
3. Read `references/build-optimization.md` before compose build.
4. Run `scripts/docker-compose-smoke.sh --check-config` before long-running actions.
5. Run compose build, optional test command, up, ps, and container smoke test.
6. Prefer container-internal checks over host `localhost` checks.

## References

- `references/verification-patterns.md`
- `references/build-optimization.md`
- `references/output-schema.md`

## Scripts

- `scripts/docker-compose-smoke.sh`

## Output handling

Use the JSON output fields `checks`, `summary`, `warnings`, and `failures`.

## Safety rules

- Do not infer missing service names, Dockerfile paths, or build contexts.
- Do not run `HEALTH_COMMAND` inside `TEST_SERVICE`; use `TEST_COMMAND` for tests.
- Stop if required values are missing.
