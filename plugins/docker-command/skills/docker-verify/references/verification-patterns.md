# verification-patterns

- `docker compose build` before `up` and smoke tests.
- `docker compose run --rm <test-service> <test-command>` only when `TEST_COMMAND` is configured.
- `docker compose up -d <app-service>` then `docker compose ps`.
- `docker compose exec -T <app-service> <health-command>` for container-internal checks.
- Avoid relying only on host localhost checks.
