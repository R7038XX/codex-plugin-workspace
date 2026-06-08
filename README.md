# Dynamic Workflows Plugin

Japanese version: [README_ja.md](README_ja.md)

This is a repo-local plugin that reuses the ideas behind Claude Dynamic
Workflows as Codex Plugins and Skills. It does not implement Claude's
JavaScript workflow runtime. Instead, it uses Codex's explicit subagent
workflow model to split large research and planning tasks into
`Scope -> Parallel Work -> Verify -> Synthesize`, starting from safe
read-only exploration.

## Structure

- `plugins/dynamic-workflows/.codex-plugin/plugin.json`: plugin manifest.
- `plugins/dynamic-workflows/skills/`: workflow skills.
- `.agents/plugins/marketplace.json`: repo-local marketplace entry.
- `README_ja.md`: Japanese README.
- `LICENSE`: MIT license.

## Skills

- `dynamic-workflow-plan`: organizes scope, phases, worker tasks, and evidence.
- `dynamic-workflow-orchestrate`: runs the full path from scoping to synthesis.
- `dynamic-workflow-run`: spawns, waits for, and synthesizes Codex subagents.
- `dynamic-workflow-review`: reviews multiple findings, merges duplicates,
  and ranks risks.
- `dynamic-workflow-status`: summarizes progress, evidence, gaps, and next
  actions.

## Usage

This repository follows the official Codex repo marketplace format. When Codex
loads `$REPO_ROOT/.agents/plugins/marketplace.json`, `dynamic-workflows` appears
as a marketplace source.

### Install

#### Fastest GitHub-based install

You do not need to download the repository manually. Add the GitHub repository
as a Codex marketplace source from the Codex CLI.

```bash
codex plugin marketplace add R7038XX/dwp \
  --ref main \
  --sparse .agents/plugins \
  --sparse plugins/dynamic-workflows
```

Then open `/plugins` in the Codex CLI, select `dynamic-workflows` from the
marketplace, and choose `Install plugin`. Start a new thread after installing.
You can also install directly after adding the marketplace source:

```bash
codex plugin add dynamic-workflows --marketplace repo-local
```

Installation options:

1. Recommended: use `codex plugin marketplace add` with the GitHub repository.
   This avoids manually downloading the repository.
2. Local testing: if you already cloned this repository, run
   `codex plugin marketplace add ./.` from the repository root.
3. Future option: publish an npm installer wrapper. This repository is
   currently distributed as a marketplace source rather than an npm package.
   npm distribution would be a separate feature that needs dependency,
   registry, vulnerability, and version pinning review.

#### Codex CLI

1. Start Codex CLI after adding the marketplace source.

   ```bash
   codex
   ```

2. Open `/plugins` from the CLI composer.
3. Select `Repo Local` from the marketplace tabs.
4. Open `dynamic-workflows`, then select `Install plugin`.
5. After installation, start a new thread and use the plugin or bundled skills.

If you already cloned this repository and want to add or manage the marketplace
source from the repository root, use the local path form.

```bash
codex plugin marketplace add ./.
codex plugin marketplace list
codex plugin marketplace upgrade repo-local
```

#### Codex app

1. Open **Plugins** in the Codex app.
2. Select `Repo Local` from the marketplace picker.
3. Open `dynamic-workflows`, then select **Add to Codex**.
4. After installation, start a new thread and use the plugin or bundled skills.

#### Codex IDE extension

Codex skills are available in the CLI, IDE extension, and Codex app. Because
this plugin is a bundle of instruction-only skills, the bundled skills can be
used in the IDE extension after the plugin is installed.

If the plugin browser is not available in your IDE extension environment,
install the plugin from the repo marketplace with the CLI or Codex app first,
then restart the IDE extension and invoke the skill.

### Invoke

Start with small-scope read-only investigation. Treat write-heavy changes as a
separate step that requires explicit approval. In the Codex app, mention
`@dynamic-workflows` or a bundled skill. In the CLI or IDE extension, invoke a
skill such as `$dynamic-workflow-plan`, or include the skill name in natural
language.

#### Basic Flow

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

#### Common Prompts

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

#### Usage Notes

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
