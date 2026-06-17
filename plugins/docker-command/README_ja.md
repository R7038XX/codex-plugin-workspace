# Docker-Command Plugin

英語版: [README.md](README.md)

関連ドキュメント:

- Workspace index: [../../README.md](../../README.md)
- Workspace index 日本語版: [../../README_ja.md](../../README_ja.md)
- Docker-Command 英語版: [README.md](README.md)

Docker-Command は Docker を使う Codex 作業向けの Plugin です。Docker の
preflight check、Docker Compose 検証、Docker 利用後の安全な cleanup を
Skill と script としてまとめます。

## 目次

- [Skills](#skills)
- [使い方](#使い方)
- [Manual script usage](#manual-script-usage)
- [Validation](#validation)
- [Safety boundary](#safety-boundary)

## Skills

- `docker-preflight`: Docker CLI、daemon、Compose、context、disk usage、
  scanner availability を Docker 作業前に確認します。
- `docker-verify`: Docker Compose の config check、build、test、startup、
  `compose ps`、container 内 smoke check を実行します。
- `docker-cleanup-safe`: dry-run plan と非破壊 cleanup を扱い、volume は削除しません。

## 使い方

root [README](../../README.md) の repository marketplace 手順で install します。
install 後は新しい Codex thread を開始してください。

Docker を使う前に `docker-preflight`、Docker Compose の検証が必要な場合に
`docker-verify`、Docker 作業後に repository 指示で cleanup が許可されている場合に
`docker-cleanup-safe` を使います。

Codex app では `@docker-command` または bundled skill を指定します。CLI /
IDE extension では `$docker-preflight` のように skill 名を指定するか、自然文に
skill 名を含めて依頼します。

## Manual script usage

script は主に Skill 経由で使いますが、対象 repository root から手動実行もできます。

`PLUGIN_DIR` にこの plugin path を設定します。

```bash
PLUGIN_DIR=/path/to/codex-plugin-workspace/plugins/docker-command
```

preflight:

```bash
"$PLUGIN_DIR/skills/docker-preflight/scripts/docker-preflight.sh"
```

build、up、exec を実行せず Docker Compose 設定だけ確認:

```bash
APP_SERVICE=app TEST_SERVICE=test HEALTH_COMMAND=true \
  TEST_COMMAND=true \
  "$PLUGIN_DIR/skills/docker-verify/scripts/docker-compose-smoke.sh" \
  --check-config
```

default cleanup の preview:

```bash
"$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" \
  --dry-run
```

scoped cleanup の preview:

```bash
CLEANUP_SCOPE_LABEL=myproject \
  "$PLUGIN_DIR/skills/docker-cleanup-safe/scripts/docker-cleanup-safe.sh" \
  --dry-run --scoped
```

## Validation

Plugin validation:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PLUGIN_DIR="$(pwd)/plugins/docker-command"

cd "$CODEX_HOME/skills/.system/plugin-creator"
python3 scripts/validate_plugin.py "$PLUGIN_DIR"
```

Skill validation:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PLUGIN_DIR="$(pwd)/plugins/docker-command"

cd "$CODEX_HOME/skills/.system/skill-creator"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-preflight"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-verify"
python3 scripts/quick_validate.py "$PLUGIN_DIR/skills/docker-cleanup-safe"
```

Script smoke checks:

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

## Safety boundary

- Docker volume は削除しません。
- cleanup script は `docker system prune -a`、`docker system prune -a --volumes`、
  `docker volume prune`、`docker builder prune -a` を実行しません。
- scanner がない場合は warning として扱い、CVE scan 成功とは見なしません。
- script output は `.env`、token、secret、personal data を出力しない設計です。
