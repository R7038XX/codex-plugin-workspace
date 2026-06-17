#!/usr/bin/env bash
set -u

if [ "${1-}" = "--help" ]; then
  cat <<'EOF_HELP'
docker-cleanup-safe
Usage: ./scripts/docker-cleanup-safe.sh [--dry-run] [--scoped]

Run non-destructive cleanup in one of three modes:
  default   : cleanup with no scope filter
  scoped    : cleanup with scope label or compose project filter
  dry-run   : output planned commands only
              (mode in JSON output is default-dry-run or scoped-dry-run)

Scope environment variables:
  CLEANUP_SCOPE_LABEL   : e.g. com.docker.compose.project=myapp
  COMPOSE_PROJECT_NAME  : scope label will include com.docker.compose.project=<value>

Prohibited commands are blocked by design:
  docker system prune -a
  docker system prune -a --volumes
  docker volume prune
  docker builder prune -a
EOF_HELP
  exit 0
fi

python3 - "$@" <<'PY'
import json
import os
import shlex
import subprocess
import sys

SCRIPT = "docker-cleanup-safe.sh"
args = sys.argv[1:]
unknown_args = [arg for arg in args if arg not in ("--dry-run", "--scoped")]
dry_run = "--dry-run" in args
scoped = "--scoped" in args
mode = "scoped-dry-run" if dry_run and scoped else ("default-dry-run" if dry_run else ("scoped" if scoped else "default"))

checks = []
warnings = []
failures = []
commands = []


FORBIDDEN_COMMANDS = {
    "docker system prune -a",
    "docker system prune -a --volumes",
    "docker volume prune",
    "docker builder prune -a",
}


def run_command(command):
    raw_command = " ".join(shlex.quote(part) for part in command)
    if raw_command in FORBIDDEN_COMMANDS:
        return 127, "", "forbidden command blocked"
    result = subprocess.run(command, capture_output=True, text=True)
    return result.returncode, (result.stdout or "")[:240], (result.stderr or "")[:240]


def make_check(name, command, status, code, out="", err=""):
    return {
        "name": name,
        "command": command,
        "status": status,
        "exit_code": code,
        "stdout_excerpt": out,
        "stderr_excerpt": err,
    }

if unknown_args:
    item = make_check("args", " ".join(unknown_args), "failed", 2, "", f"unsupported args: {', '.join(unknown_args)}")
    print(json.dumps({
        "status": "failed",
        "script": SCRIPT,
        "mode": mode,
        "checks": [item],
        "warnings": [],
        "failures": [item],
        "commands": [],
        "summary": "invalid arguments",
    }, ensure_ascii=False))
    raise SystemExit(2)

scope_label = os.getenv("CLEANUP_SCOPE_LABEL", "").strip()
compose_project = os.getenv("COMPOSE_PROJECT_NAME", "").strip()
filters = []

if scope_label:
    if "\n" in scope_label:
        failures.append(make_check("CLEANUP_SCOPE_LABEL", scope_label, "failed", 2, "", "invalid input"))
    elif scoped:
        filters.append(f"label={scope_label}")
if compose_project:
    if "\n" in compose_project:
        failures.append(make_check("COMPOSE_PROJECT_NAME", compose_project, "failed", 2, "", "invalid input"))
    elif scoped:
        filters.append(f"label=com.docker.compose.project={compose_project}")

if not scoped:
    if scope_label or compose_project:
        warnings.append(make_check("scope", "default mode", "warning", 0, "", "scope env ignored without --scoped"))
    else:
        warnings.append(make_check("scope", "global", "warning", 0, "", "scope was not provided; cleanup uses default mode"))

if scoped and not filters:
    item = make_check("scope", "scoped mode", "failed", 2, "", "requires CLEANUP_SCOPE_LABEL or COMPOSE_PROJECT_NAME")
    failures.append(item)
    print(json.dumps({
        "status": "failed",
        "script": SCRIPT,
        "mode": mode,
        "checks": [item],
        "warnings": [],
        "failures": [item],
        "commands": [],
        "summary": "scoped mode requires scope",
    }, ensure_ascii=False))
    raise SystemExit(2)

commands_plan = [["docker", "system", "df"]]
if filters:
    for base in [
        ["docker", "container", "prune", "-f"],
        ["docker", "image", "prune", "-f"],
        ["docker", "builder", "prune", "-f"],
        ["docker", "network", "prune", "-f"],
    ]:
        command = base + ["--filter", filters[0]]
        if len(filters) > 1:
            for extra_filter in filters[1:]:
                command.extend(["--filter", extra_filter])
        commands_plan.append(command)
else:
    commands_plan.extend([
        ["docker", "container", "prune", "-f"],
        ["docker", "image", "prune", "-f"],
        ["docker", "builder", "prune", "-f"],
        ["docker", "network", "prune", "-f"],
    ])

if not filters:
    commands_plan.append(["docker", "system", "df"])
else:
    commands_plan.append(["docker", "system", "df"])

forbidden_in_plan = [" ".join(command) for command in commands_plan if " ".join(command) in FORBIDDEN_COMMANDS]
if forbidden_in_plan:
    warnings.append(make_check("prohibited", "; ".join(forbidden_in_plan), "warning", 0, "", "forbidden command removed from execution"))

commands_plan_text = [" ".join(command) for command in commands_plan]
for command in commands_plan:
    checks.append(make_check("command", " ".join(command), "skipped" if dry_run else "pending", 0, "", ""))

if dry_run:
    status = "failed" if failures else ("warning" if warnings else "passed")
    print(json.dumps({
        "status": status,
        "script": SCRIPT,
        "mode": mode,
        "checks": checks,
        "warnings": warnings,
        "failures": failures,
        "commands": commands_plan_text,
        "summary": "dry-run validation failed" if failures else "dry-run completed; no commands executed",
    }, ensure_ascii=False))
    raise SystemExit(2 if failures else 0)

status = "passed"
for command in commands_plan:
    raw_command = " ".join(command)
    code, out, err = run_command(command)
    command_status = "passed" if code == 0 else "failed"
    if code != 0:
        status = "failed"
        failures.append(make_check("command", raw_command, "failed", code, out, err))
    commands.append(raw_command)

    checks.append(make_check("command", raw_command, command_status, code, out, err))

print(json.dumps({
    "status": status,
    "script": SCRIPT,
    "mode": mode,
    "checks": checks,
    "warnings": warnings,
    "failures": failures,
    "commands": commands,
    "summary": "cleanup completed" if status == "passed" else "cleanup completed with failures",
}, ensure_ascii=False))
raise SystemExit(0 if status == "passed" else 1)
PY
