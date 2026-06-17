#!/usr/bin/env bash
set -u

if [ "${1-}" = "--help" ]; then
  cat <<'EOF_HELP'
docker-compose-smoke
Usage: ./scripts/docker-compose-smoke.sh [--check-config]

Run docker-compose verification workflow.
  --check-config: validate configuration only.
  --help: display this help text.

Environment variables:
  Required: APP_SERVICE, TEST_SERVICE, HEALTH_COMMAND
  Optional: COMPOSE_FILE, COMPOSE_PROFILES, TEST_COMMAND, BUILD_CONTEXT, DOCKERFILE_PATH, STACK_KIND
EOF_HELP
  exit 0
fi

python3 - "$@" <<'PY'
import json
import os
import pathlib
import re
import subprocess
import sys

SCRIPT = "docker-compose-smoke.sh"
args = sys.argv[1:]
unknown_args = [arg for arg in args if arg != "--check-config"]
check_config = "--check-config" in args
mode = "check-config" if check_config else "run"

checks = []
warnings = []
failures = []
commands = []


def redacted(text):
    if text is None:
        return ""
    patterns = [
        r"(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key|auth|credential)\s*[:=]\s*[^\s]+",
        r"(?i)(bearer|basic)\s+[A-Za-z0-9._~+/=-]+",
        r"(?i)(--(?:password|secret|token|api-key|build-arg|env)(?:=|\s+))[^\s]+",
    ]
    value = str(text).replace("\r", "")
    for pattern in patterns:
        value = re.sub(pattern, r"\1[redacted]", value)
    return value


def make_check(name, command, status, code, stdout="", stderr=""):
    return {
        "name": name,
        "command": redacted(command)[:240],
        "status": status,
        "exit_code": code,
        "stdout_excerpt": redacted(stdout)[:240],
        "stderr_excerpt": redacted(stderr)[:240],
    }


def run_command(command, env):
    proc = subprocess.run(command, capture_output=True, text=True, env=env)
    return proc.returncode, proc.stdout, proc.stderr


def check_required(name, value):
    if not value or "\n" in value:
        failures.append(make_check(name, "env-check", "failed", 2, "", "invalid input"))
        return False
    return True

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

compose_file = os.getenv("COMPOSE_FILE", "").strip()
compose_profiles = os.getenv("COMPOSE_PROFILES", "").strip()
app_service = os.getenv("APP_SERVICE", "").strip()
test_service = os.getenv("TEST_SERVICE", "").strip()
health_command = os.getenv("HEALTH_COMMAND", "").strip()
test_command = os.getenv("TEST_COMMAND", "").strip()
build_context = os.getenv("BUILD_CONTEXT", "").strip()
dockerfile_path = os.getenv("DOCKERFILE_PATH", "").strip()
stack_kind = os.getenv("STACK_KIND", "").strip()

if not check_required("APP_SERVICE", app_service):
    pass
if not check_required("TEST_SERVICE", test_service):
    pass
if not check_required("HEALTH_COMMAND", health_command):
    pass
if test_command and "\n" in test_command:
    failures.append(make_check("TEST_COMMAND", "env-check", "failed", 2, "", "invalid input"))

if compose_file:
    for file_name in compose_file.split(os.pathsep):
        if not file_name:
            failures.append(make_check("COMPOSE_FILE", "path=<empty>", "failed", 2, "", "empty path"))
            continue
        compose_path = pathlib.Path(file_name)
        if not compose_path.exists():
            failures.append(make_check("COMPOSE_FILE", f"path={file_name}", "failed", 2, "", "not found"))
        elif not compose_path.is_file():
            failures.append(make_check("COMPOSE_FILE", f"path={file_name}", "failed", 2, "", "not a file"))

if compose_profiles:
    if not compose_profiles.strip() or "\n" in compose_profiles:
        failures.append(make_check("COMPOSE_PROFILES", "validation", "failed", 2, "", "invalid input"))

if build_context:
    build_context_path = pathlib.Path(build_context)
    if not build_context_path.exists():
        failures.append(make_check("BUILD_CONTEXT", f"value={build_context}", "failed", 2, "", "not found"))
    elif not build_context_path.is_dir():
        failures.append(make_check("BUILD_CONTEXT", f"value={build_context}", "failed", 2, "", "not a directory"))
else:
    build_context_path = None

if stack_kind and not stack_kind.strip():
    failures.append(make_check("STACK_KIND", "validation", "failed", 2, "", "blank value"))

if stack_kind == "nextjs":
    if not build_context_path or not build_context_path.exists():
        failures.append(make_check("BUILD_CONTEXT", "required for nextjs", "failed", 2, "", "missing or invalid"))
    else:
        dockerignore = build_context_path / ".dockerignore"
        if not dockerignore.exists():
            failures.append(make_check(".dockerignore", "validation", "failed", 2, "", "required for nextjs"))
        else:
            dockerignore_content = dockerignore.read_text(errors="ignore")
            if ".next" not in dockerignore_content:
                failures.append(make_check(".dockerignore", "validation", "failed", 2, "", ".next missing"))
            if "node_modules" not in dockerignore_content:
                failures.append(make_check(".dockerignore", "validation", "failed", 2, "", "node_modules missing"))

if dockerfile_path:
    dockerfile_path_obj = pathlib.Path(dockerfile_path)
    if not dockerfile_path_obj.exists():
        failures.append(make_check("DOCKERFILE_PATH", dockerfile_path, "failed", 2, "", "not found"))
    elif not dockerfile_path_obj.is_file():
        failures.append(make_check("DOCKERFILE_PATH", dockerfile_path, "failed", 2, "", "not a file"))
else:
    dockerfile_path_obj = build_context_path / "Dockerfile" if build_context_path else None

candidate = pathlib.Path(dockerfile_path_obj) if dockerfile_path_obj else None
if candidate and candidate.exists():
    content = candidate.read_text(errors="ignore")
    if re.search(r"FROM .+:latest", content):
        warnings.append(make_check("base_image_latest", "Dockerfile", "warning", 0, "", "latest tag found"))
    if "--mount=type=cache" not in content:
        warnings.append(make_check("buildkit_cache_mount", "Dockerfile", "warning", 0, "", "cache mount could be added"))

env = os.environ.copy()
if compose_file:
    env["COMPOSE_FILE"] = compose_file
if compose_profiles:
    env["COMPOSE_PROFILES"] = compose_profiles

if not failures:
    config_command = ["docker", "compose", "config", "--services"]
    code, out, err = run_command(config_command, env)
    cmd_text = " ".join(config_command)
    commands.append(redacted(cmd_text)[:240])
    check = make_check(
        "compose_config_services",
        cmd_text,
        "passed" if code == 0 else "failed",
        code,
        out,
        err,
    )
    checks.append(check)
    if code != 0:
        failures.append(check)
    else:
        services = {line.strip() for line in out.splitlines() if line.strip()}
        for required_service in (app_service, test_service):
            if required_service not in services:
                failures.append(make_check(
                    "compose_service",
                    f"service={required_service}",
                    "failed",
                    2,
                    "",
                    "service not found in docker compose config",
                ))

if check_config:
    status = "failed" if failures else ("warning" if warnings else "passed")
    if failures:
        summary = "verification config has failures"
    elif warnings:
        summary = "verification config completed with warnings"
    else:
        summary = "verification config passed"
    print(json.dumps({
        "status": status,
        "script": SCRIPT,
        "mode": mode,
        "checks": checks,
        "warnings": warnings,
        "failures": failures,
        "commands": commands,
        "summary": summary,
    }, ensure_ascii=False))
    raise SystemExit(2 if failures else 0)

if failures:
    print(json.dumps({
        "status": "failed",
        "script": SCRIPT,
        "mode": mode,
        "checks": checks,
        "warnings": warnings,
        "failures": failures,
        "commands": commands,
        "summary": "verification config has failures",
    }, ensure_ascii=False))
    raise SystemExit(2)
status = "warning" if warnings else "passed"
workflow = [
    ["docker", "compose", "build"],
    ["docker", "compose", "up", "-d", app_service],
    ["docker", "compose", "ps"],
    ["docker", "compose", "exec", "-T", app_service, "sh", "-lc", health_command],
]
if test_command:
    workflow.insert(1, ["docker", "compose", "run", "--rm", test_service, "sh", "-lc", test_command])
else:
    warnings.append(make_check("test_command", "TEST_COMMAND", "warning", 0, "", "not configured; test service run skipped"))

for command in workflow:
    code, out, err = run_command(command, env)
    cmd_text = " ".join(command)
    commands.append(redacted(cmd_text)[:240])
    check = make_check("command", cmd_text, "passed" if code == 0 else "failed", code, out, err)
    checks.append(check)
    if code != 0:
        failures.append(check)
        status = "failed"

if status != "failed" and warnings:
    status = "warning"

print(json.dumps({
    "status": status,
    "script": SCRIPT,
    "mode": mode,
    "checks": checks,
    "warnings": warnings,
    "failures": failures,
    "commands": commands,
    "summary": "compose verification failed" if status == "failed" else ("compose verification completed with warnings" if status == "warning" else "compose verification completed"),
}, ensure_ascii=False))
raise SystemExit(1 if status == "failed" else 0)
PY
