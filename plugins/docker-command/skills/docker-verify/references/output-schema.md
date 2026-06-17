# output-schema

Common result schema:

```json
{
  "status": "passed|warning|failed",
  "script": "docker-compose-smoke.sh",
  "mode": "default|check-config|run",
  "checks": [],
  "warnings": [],
  "failures": [],
  "commands": [],
  "summary": "short summary"
}
```

Passed example:

```json
{
  "status": "passed",
  "script": "docker-compose-smoke.sh",
  "mode": "check-config",
  "checks": [
    {"name":"config_validation","command":"config","status":"passed","exit_code":0}
  ],
  "warnings": [],
  "failures": [],
  "commands": [],
  "summary": "config valid"
}
```

Warning example:

```json
{
  "status": "warning",
  "script": "docker-compose-smoke.sh",
  "mode": "run",
  "checks": [],
  "warnings": [{"name":"dockerfile_copy_order","status":"warning","exit_code":0}],
  "failures": [],
  "commands": ["docker compose build"],
  "summary": "warnings only"
}
```

Failed example:

```json
{
  "status": "failed",
  "script": "docker-compose-smoke.sh",
  "mode": "check-config",
  "checks": [
    {"name":"APP_SERVICE","command":"env-check","status":"failed","exit_code":2}
  ],
  "warnings": [],
  "failures": [
    {"name":"APP_SERVICE","command":"env-check","status":"failed","exit_code":2}
  ],
  "commands": [],
  "summary": "missing required env vars"
}
```
