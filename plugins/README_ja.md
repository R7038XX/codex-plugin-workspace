# Codex Plugin Workspace

英語版: [../README.md](../README.md)

関連ドキュメント:

- Workspace index: [../README.md](../README.md)
- Dynamic Workflows: [dynamic-workflows/README.md](dynamic-workflows/README.md)
- Dynamic Workflows 日本語版: [dynamic-workflows/README_ja.md](dynamic-workflows/README_ja.md)

この repository は repo-local Codex plugin workspace です。1 つ以上の
Plugin を `plugins/` 配下で管理し、`.agents/plugins/marketplace.json` から
repo marketplace として公開します。

## 目次

- [Workspace 構成](#workspace-構成)
- [利用可能な Plugin](#利用可能な-plugin)
- [Install](#install)
- [Plugin 管理](#plugin-管理)
- [ドキュメント方針](#ドキュメント方針)
- [License](#license)

## Workspace 構成

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

- `.agents/plugins/marketplace.json`: repo-local marketplace 定義。
- `plugins/README_ja.md`: 日本語の workspace-level Plugin index。
- `plugins/<plugin-name>/.codex-plugin/plugin.json`: 各 Plugin の manifest。
- `plugins/<plugin-name>/README.md`: Plugin ごとの使い方、挙動、prompt 例。
- `plugins/<plugin-name>/README_ja.md`: 日本語版を管理する場合の個別 README。

## 利用可能な Plugin

| Plugin | 概要 | ドキュメント |
| --- | --- | --- |
| `dynamic-workflows` | Codex-native な planning、fan-out、review、status workflow。 | [README](dynamic-workflows/README.md) / [日本語](dynamic-workflows/README_ja.md) |

## Install

### GitHub marketplace source

この repository を Codex marketplace source として追加します。

```bash
codex plugin marketplace add R7038XX/dwp \
  --ref main \
  --sparse .agents/plugins \
  --sparse plugins
```

その後、Codex CLI で `/plugins` を開き、repo marketplace から必要な Plugin を
install します。

marketplace source を追加した後は、次のコマンドでも直接 install できます。

```bash
codex plugin add dynamic-workflows --marketplace repo-local
```

### Local marketplace source

この repository を clone 済みの場合は、repository root から追加できます。

```bash
codex plugin marketplace add ./.
codex plugin marketplace list
```

追加済み marketplace source を更新する場合:

```bash
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

## ドキュメント方針

root README と `plugins/README_ja.md` は workspace 全体の情報に絞ります。
目次、install 方法、repository 構成、Plugin index だけを置き、Plugin 固有の
使い方、Skill 一覧、prompt 例、挙動、security boundary は各 Plugin の
README に置きます。

## License

MIT. 詳細は [../LICENSE](../LICENSE) を参照してください。
