# Dynamic Workflows Plugin

Japanese version: [README_ja.md](README_ja.md)

Related documents:

- Workspace index: [../../README.md](../../README.md)
- Workspace index 日本語版: [../../README_ja.md](../../README_ja.md)
- Dynamic Workflows 日本語版: [README_ja.md](README_ja.md)

This plugin reuses the ideas behind Claude Dynamic Workflows as Codex Plugins
and Skills. It does not implement Claude's JavaScript workflow runtime.
Instead, it uses Codex's explicit subagent workflow model to split large
research and planning tasks into `Scope -> Parallel Work -> Verify ->
Synthesize`, starting from safe read-only exploration.

## Table of Contents

- [Skills](#skills)
- [Usage](#usage)
- [Basic Flow](#basic-flow)
- [Common Prompts](#common-prompts)
- [Usage Notes](#usage-notes)
- [Security Boundary](#security-boundary)
- [Official Documentation Basis](#official-documentation-basis)

## Skills

- `dynamic-workflow-plan`: organizes scope, phases, worker tasks, and evidence.
- `dynamic-workflow-orchestrate`: runs the full path from scoping to synthesis.
- `dynamic-workflow-run`: spawns, waits for, and synthesizes Codex subagents.
- `dynamic-workflow-review`: reviews multiple findings, merges duplicates, and
  ranks risks.
- `dynamic-workflow-status`: summarizes progress, evidence, gaps, and next
  actions.

## Usage

Install this plugin from the repository marketplace documented in the root
[README](../../README.md). After installation, start a new Codex thread before
using the bundled skills.

Start with small-scope read-only investigation. Treat write-heavy changes as a
separate step that requires explicit approval. In the Codex app, mention
`@dynamic-workflows` or a bundled skill. In the CLI or IDE extension, invoke a
skill such as `$dynamic-workflow-plan`, or include the skill name in natural
language.

## Basic Flow

1. Use `dynamic-workflow-plan` to define scope, worker tasks, and verification
   angles.
2. Use `dynamic-workflow-run` to execute read-only subagent fan-out.
3. Use `dynamic-workflow-review` to merge findings, challenge assumptions, and
   rank risks.
4. Use `dynamic-workflow-status` to share completed work, missing evidence, and
   next actions.

Use `dynamic-workflow-orchestrate` when you want the full workflow in one pass.
Implementation or other write-heavy work must still be approved as a separate
step.

## Common Prompts

Plan a large task before starting work:

```text
$dynamic-workflow-plan
Create a release-readiness investigation plan for this repo.
Separate read-only and write phases, and summarize worker tasks, verification,
risks, and open questions in Japanese.
```

Run read-only fan-out:

```text
$dynamic-workflow-run
Investigate this repo's release readiness with 3 read-only subagents:
Security, Test/Build, and Documentation. Spawn one subagent per angle,
wait for all of them, then synthesize the findings in Japanese.
Do not modify files.
```

Run the plan-to-synthesis path in one pass:

```text
$dynamic-workflow-orchestrate
Run this repo's release readiness as a Codex-native Dynamic Workflow.
Split it into 3 read-only subagents, wait for all of them, run an adversarial
review, and synthesize the final result in Japanese.
```

Review multiple worker outputs:

```text
$dynamic-workflow-review
Merge the worker findings below. Summarize duplicates, counterarguments,
severity, missing evidence, security concerns, and recommended actions
in Japanese.
```

Summarize current progress:

```text
$dynamic-workflow-status
Summarize the current workflow status in Japanese using completed work,
verification results, remaining work, risks, and next actions.
```

## Usage Notes

- Subagents are used only when explicitly requested.
- If subagents are unavailable in the active surface, fall back to a sequential
  checklist.
- Do not include secrets, `.env`, credentials, or personal information in
  prompts or evidence.
- For broad repository investigations, start with 2 to 5 bounded workers.
- Keep implementation, deletion, dependency additions, and external API usage
  separate from read-only investigation.

## Security Boundary

- The workflow does not collect or output secrets, `.env` files, credentials,
  or personal information.
- External APIs, MCP servers, ChatGPT Apps, Docker images, and GitHub Actions
  are outside the initial scope.
- Write phases are separated from read-only investigation and review.

## Official Documentation Basis

- Codex manual `Plugins`: CLI users open `/plugins` to browse plugins, install
  or uninstall them, and toggle enabled state.
- Codex manual `Build plugins`: repo-scoped marketplaces use
  `$REPO_ROOT/.agents/plugins/marketplace.json`, and `source.path` is a
  `./`-prefixed path relative to the marketplace root.
- Codex manual `Agent Skills`: skills are available in Codex CLI, IDE
  extension, and Codex app.
- Codex manual `Subagents`: Codex spawns subagents only when explicitly asked,
  waits for results, and synthesizes them.
