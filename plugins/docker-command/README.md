# Docker-Command Plugin

Japanese version: [README_ja.md](README_ja.md)

Related documents:

- Workspace index: [../../README.md](../../README.md)
- Workspace index 日本語版: [../../README_ja.md](../../README_ja.md)
- Docker-Command 日本語版: [README_ja.md](README_ja.md)

Docker-Command is a Codex Plugin for Docker-backed work. It bundles skills and
scripts for Docker preflight checks, Docker Compose verification, and safe
cleanup after Docker use.

## Table of Contents

- [Skills](#skills)
- [Usage](#usage)
- [Manual Script Usage](#manual-script-usage)
- [Validation](#validation)
- [Safety Boundary](#safety-boundary)

## Skills

- `docker-preflight`: checks Docker CLI, daemon, Compose, context, disk usage,
  and scanner availability before Docker-backed work.
- `docker-verify`: runs Docker Compose configuration checks, build, test,
  startup, `compose ps`, and container-internal smoke checks.
- `docker-cleanup-safe`: prepares dry-run plans and runs non-destructive Docker
  cleanup without deleting volumes.

## Usage

Install this plugin from the repository marketplace documented in the root
[README](../../README.md). After installation, start a new Codex thread before
using the bundled skills.

Use `docker-preflight` before Docker-backed work, `docker-verify` when a
repository needs Docker Compose validation, and `docker-cleanup-safe` after
Docker work when cleanup is allowed by the repository instructions.

In the Codex app, mention `@docker-command` or a bundled skill. In the CLI or
IDE extension, invoke a skill such as `$docker-preflight`, or include the skill
name in natural language.

## Manual Script Usage

The scripts are primarily used through skills, but can also be run manually
from a target repository root.

Set `PLUGIN_DIR` to this plugin path:

```bash
PLUGIN_DIR=/path/to/codex-plugin-workspace/plugins/docker-command
```

Run preflight:

```bash
"$PLUGIN_DIR/skills/docker-preflight/scripts/docker-preflight.sh"
```

Validate Docker Compose settings without running build, up, or exec:

```bash
APP_SERVICE=app TEST_SERVICE=test HEALTH_COMMAND=true \
  TEST_COMMAND=true \
  "$PLUGIN_DIR/skills/docker-verify/scripts/docker-compose-smoke.sh" \
  --check-config
```

Preview default cleanup:

```bash
"$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" \
  --dry-run
```

Preview scoped cleanup:

```bash
CLEANUP_SCOPE_LABEL=myproject \
  "$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" \
  --dry-run --scoped
```

## Validation

Run plugin validation:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PLUGIN_DIR="$(pwd)/plugins/docker-command"

cd "$CODEX_HOME/skills/.system/plugin-creator"
python3 scripts/validate_plugin.py "$PLUGIN_DIR"
```

Run skill validation:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PLUGIN_DIR="$(pwd)/plugins/docker-command"

cd "$CODEX_HOME/skills/.system/skill-creator"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-preflight"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-verify"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-cleanup-safe"
```

Run script smoke checks:

```bash
PLUGIN_DIR=plugins/docker-command

"$PLUGIN_DIR/skills/docker-preflight/scripts/docker-preflight.sh" --help
"$PLUGIN_DIR/skills/docker-verify/scripts/docker-compose-smoke.sh" --help
tmpdir=$(mktemp -d)
cat > "$tmpdir/compose.yaml" <<'YAML'
services:
  app:
    image: busybox:1.36
  test:
    image: busybox:1.36
YAML
APP_SERVICE=app TEST_SERVICE=test HEALTH_COMMAND=true \
  TEST_COMMAND=true \
  COMPOSE_FILE="$tmpdir/compose.yaml" \
  "$PLUGIN_DIR/skills/docker-verify/scripts/docker-compose-smoke.sh" \
  --check-config
rm -rf "$tmpdir"
"$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" --help
"$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" \
  --dry-run
```

## Safety Boundary

- The plugin does not delete Docker volumes.
- The cleanup script does not run `docker system prune -a`,
  `docker system prune -a --volumes`, `docker volume prune`, or
  `docker builder prune -a`.
- Scanner absence is reported as a warning, not as a successful CVE scan.
- Script output is designed to avoid printing `.env`, tokens, secrets, or
  personal data.
