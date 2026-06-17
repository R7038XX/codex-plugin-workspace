# Codex Plugin Workspace

英語版: [README.md](README.md)

関連ドキュメント:

| ドキュメント | リンク |
| --- | --- |
| Workspace index | [README.md](README.md) |
| Dynamic Workflows | [plugins/dynamic-workflows/README.md](plugins/dynamic-workflows/README.md) |
| Dynamic Workflows 日本語版 | [plugins/dynamic-workflows/README_ja.md](plugins/dynamic-workflows/README_ja.md) |
| Docker-Command | [plugins/docker-command/README.md](plugins/docker-command/README.md) |
| Docker-Command 日本語版 | [plugins/docker-command/README_ja.md](plugins/docker-command/README_ja.md) |

この repository は repo-local Codex plugin workspace です。Plugin を
`plugins/` 配下で管理し、`.agents/plugins/marketplace.json` から repo
marketplace として公開します。

## 目次

- [Workspace 構成](#workspace-構成)
- [利用可能な Plugin](#利用可能な-plugin)
- [Install](#install)
- [Plugin 管理](#plugin-管理)
- [License](#license)

## Workspace 構成

```text
.
├── .agents/plugins/marketplace.json
├── plugins/
│   ├── docker-command/
│   │   ├── .codex-plugin/plugin.json
│   │   ├── README.md
│   │   ├── README_ja.md
│   │   └── skills/
│   └── dynamic-workflows/
│       ├── .codex-plugin/plugin.json
│       ├── README.md
│       ├── README_ja.md
│       └── skills/
├── README.md
└── LICENSE
```

## 利用可能な Plugin

| Plugin | 概要 | ドキュメント |
| --- | --- | --- |
| `docker-command` | Docker preflight、Compose 検証、安全な cleanup workflow。 | [README](plugins/docker-command/README.md) / [日本語](plugins/docker-command/README_ja.md) |
| `dynamic-workflows` | Codex-native な planning、fan-out、review、status workflow。 | [README](plugins/dynamic-workflows/README.md) / [日本語](plugins/dynamic-workflows/README_ja.md) |

## Install

この repository を Codex marketplace source として追加します。

```bash
codex plugin marketplace add R7038XX/codex-plugin-workspace \
  --ref main \
  --sparse .agents/plugins \
  --sparse plugins
```

その後、Codex CLI で `/plugins` を開き、repo marketplace から必要な Plugin を
install します。

marketplace source を追加した後は、次のコマンドでも直接 install できます。

```bash
codex plugin add docker-command --marketplace repo-local
codex plugin add dynamic-workflows --marketplace repo-local
```

clone 済みの repository root から marketplace source を追加・管理したい場合:

```bash
codex plugin marketplace add ./.
codex plugin marketplace list
codex plugin marketplace upgrade repo-local
```

Plugin の install または upgrade 後は、新しい Codex thread を開始してください。

## Plugin 管理

この workspace に別 Plugin を追加する場合:

1. `plugins/<plugin-name>/.codex-plugin/plugin.json` を作成する。
2. `plugins/<plugin-name>/README.md` に個別ドキュメントを置く。
3. `.agents/plugins/marketplace.json` に対応する entry を追加する。
4. release 前に Plugin manifest と marketplace entry を検証する。

marketplace entry の path は repository root からの相対 path にします。

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

## License

MIT. 詳細は [LICENSE](LICENSE) を参照してください。
