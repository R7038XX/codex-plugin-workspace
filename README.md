# Codex Plugin Workspace

Japanese version: [plugins/README_ja.md](plugins/README_ja.md)

Related documents:

- Workspace index: [plugins/README_ja.md](plugins/README_ja.md)
- Dynamic Workflows: [plugins/dynamic-workflows/README.md](plugins/dynamic-workflows/README.md)
- Dynamic Workflows 日本語版: [plugins/dynamic-workflows/README_ja.md](plugins/dynamic-workflows/README_ja.md)

This repository is a repo-local Codex plugin workspace. It manages one or more
plugins under `plugins/` and exposes them through the repo marketplace at
`.agents/plugins/marketplace.json`.

## Table of Contents

- [Workspace Structure](#workspace-structure)
- [Available Plugins](#available-plugins)
- [Install](#install)
- [Manage Plugins](#manage-plugins)
- [Documentation Policy](#documentation-policy)
- [License](#license)

## Workspace Structure

```text
.
├── .agents/plugins/marketplace.json
├── plugins/
│   ├── README_ja.md
│   └── dynamic-workflows/
│       ├── .codex-plugin/plugin.json
│       ├── README.md
│       ├── README_ja.md
│       └── skills/
├── README.md
└── LICENSE
```

- `.agents/plugins/marketplace.json`: repo-local marketplace definition.
- `plugins/README_ja.md`: Japanese workspace-level plugin index.
- `plugins/<plugin-name>/.codex-plugin/plugin.json`: each plugin manifest.
- `plugins/<plugin-name>/README.md`: plugin-specific usage, behavior, and
  prompts.
- `plugins/<plugin-name>/README_ja.md`: Japanese plugin-specific README when
  maintained.

## Available Plugins

| Plugin | Summary | Documentation |
| --- | --- | --- |
| `dynamic-workflows` | Codex-native planning, fan-out, review, and status workflows. | [README](plugins/dynamic-workflows/README.md) / [日本語](plugins/dynamic-workflows/README_ja.md) |

## Install

### GitHub Marketplace Source

Add this repository as a Codex marketplace source:

```bash
codex plugin marketplace add R7038XX/dwp \
  --ref main \
  --sparse .agents/plugins \
  --sparse plugins
```

Then open `/plugins` in Codex CLI, select the repo marketplace, and install the
plugin you need.

You can also install a plugin directly after adding the marketplace source:

```bash
codex plugin add dynamic-workflows --marketplace repo-local
```

### Local Marketplace Source

If this repository is already cloned, add it from the repository root:

```bash
codex plugin marketplace add ./.
codex plugin marketplace list
```

To refresh an already added marketplace source:

```bash
codex plugin marketplace upgrade repo-local
```

Start a new Codex thread after installing or upgrading plugins.

## Manage Plugins

To add another plugin to this workspace:

1. Create `plugins/<plugin-name>/.codex-plugin/plugin.json`.
2. Add plugin-specific documentation at `plugins/<plugin-name>/README.md`.
3. Add a matching entry to `.agents/plugins/marketplace.json`.
4. Validate the plugin manifest and marketplace entry before release.

Marketplace entries use paths relative to the repository root:

```json
{
  "name": "plugin-name",
  "source": {
    "source": "local",
    "path": "./plugins/plugin-name"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

## Documentation Policy

Keep this root README focused on workspace-level information: table of contents,
installation, repository structure, and plugin index. Put plugin-specific usage,
skill lists, prompts, behavior, and security boundaries in each plugin's own
README.

## License

MIT. See [LICENSE](LICENSE).
