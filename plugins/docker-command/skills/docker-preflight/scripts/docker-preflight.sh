#!/usr/bin/env bash
set -u

if [ "${1-}" = "--help" ]; then
  cat <<'EOF_HELP'
docker-preflight
Usage: ./scripts/docker-preflight.sh [--help]

Run fixed Docker preflight checks and output JSON.
EOF_HELP
  exit 0
fi

python3 - <<'PY'
import json
import re
import shutil
import subprocess

SCRIPT = "docker-preflight.sh"

def redacted(text: str) -> str:
    if text is None:
        return ""
    pattern = re.compile(r"(?i)(?:password|secret|token|api[_-]?key)\s*[:=]\s*[^\s]+")
    return pattern.sub("[redacted]", str(text)).replace("\r", "")[:240]

def make_check(name, command, fail_status="failed"):
    try:
        proc = subprocess.run(command, capture_output=True, text=True, timeout=120)
        exit_code = proc.returncode
        out = redacted(proc.stdout)
        err = redacted(proc.stderr)
        status = "passed" if exit_code == 0 else fail_status
    except FileNotFoundError:
        exit_code = 127
        out = ""
        err = "command not found"
        status = fail_status
    except Exception as exc:  # pragma: no cover
        exit_code = 1
        out = ""
        err = redacted(str(exc))
        status = fail_status

    return {
        "name": name,
        "command": " ".join(command),
        "status": status,
        "exit_code": exit_code,
        "stdout_excerpt": out,
        "stderr_excerpt": err,
    }

checks = []
warnings = []
failures = []
commands = []

for req in [
    ("docker_version", ["docker", "version"], "failed"),
    ("docker_compose_version", ["docker", "compose", "version"], "failed"),
    ("docker_context_show", ["docker", "context", "show"], "failed"),
    ("docker_ps", ["docker", "ps"], "warning"),
    ("docker_system_df", ["docker", "system", "df"], "warning"),
]:
    item = make_check(*req)
    checks.append(item)
    commands.append(item["command"])
    if item["status"] == "failed":
        failures.append(item)
    elif item["status"] == "warning":
        warnings.append(item)

docker_binary = shutil.which("docker")
item = {
    "name": "docker_cli",
    "command": "command -v docker",
    "status": "passed" if docker_binary else "failed",
    "exit_code": 0 if docker_binary else 127,
    "stdout_excerpt": docker_binary or "",
    "stderr_excerpt": "" if docker_binary else "command not found",
}
checks.append(item)
commands.append(item["command"])
if item["status"] == "failed":
    failures.append(item)


if shutil.which("trivy"):
    item = make_check("trivy_presence", ["trivy", "--version"], "warning")
    checks.append(item)
    commands.append(item["command"])
    if item["status"] != "passed":
        warnings.append(item)
else:
    warnings.append({
        "name": "not_run_scanner_unavailable",
        "command": "trivy --version",
        "status": "warning",
        "exit_code": 127,
        "stdout_excerpt": "",
        "stderr_excerpt": "trivy not found",
    })

item = make_check("docker_scout_presence", ["docker", "scout", "version"], "warning")
checks.append(item)
commands.append(item["command"])
if item["status"] == "warning":
    scanner_warning = item.copy()
    scanner_warning["name"] = "not_run_scanner_unavailable"
    warnings.append(scanner_warning)

status = "passed"
if any(item["status"] == "failed" for item in checks):
    status = "failed"
elif warnings:
    status = "warning"

payload = {
    "status": status,
    "script": SCRIPT,
    "mode": "default",
    "checks": checks,
    "warnings": warnings,
    "failures": failures,
    "commands": commands,
    "summary": f"Docker preflight completed with status={status}",
}

print(json.dumps(payload, ensure_ascii=False))
raise SystemExit(0 if status != "failed" else 1)
PY
