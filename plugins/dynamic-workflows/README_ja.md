# Dynamic Workflows Plugin

英語版: [README.md](README.md)

関連ドキュメント:

- Workspace index: [../../README.md](../../README.md)
- Workspace index 日本語版: [../README_ja.md](../README_ja.md)
- Dynamic Workflows: [README.md](README.md)

Claude Dynamic Workflows の考え方を Codex Plugin と Skill で再利用する
Plugin です。Claude の JavaScript workflow runtime ではなく、Codex の
明示的な subagent workflow を使って大きな調査や計画を
`Scope -> Parallel Work -> Verify -> Synthesize` に分け、read-only の
安全な探索から開始できるようにします。

## 目次

- [Skills](#skills)
- [使い方](#使い方)
- [基本フロー](#基本フロー)
- [よく使う依頼例](#よく使う依頼例)
- [利用時の注意](#利用時の注意)
- [Security Boundary](#security-boundary)
- [公式ドキュメント根拠](#公式ドキュメント根拠)

## Skills

- `dynamic-workflow-plan`: scope、phase、worker task、検証 evidence を整理。
- `dynamic-workflow-orchestrate`: scope から final synthesis までを一括実行。
- `dynamic-workflow-run`: Codex subagents を spawn、wait、synthesize する。
- `dynamic-workflow-review`: 複数結果を adversarial に review し、重複と risk を統合。
- `dynamic-workflow-status`: 進捗、根拠、未検証範囲、次アクションを要約。

## 使い方

workspace [README](../README_ja.md) の repository marketplace 手順でこの Plugin を
install します。install 後は、新しい Codex thread を開始してから bundled skill を
使ってください。

小さい scope の read-only 調査から始め、write-heavy な変更は別 step として
明示的に承認してから実行します。Codex app では `@dynamic-workflows` または
bundled skill を明示し、CLI / IDE extension では `$dynamic-workflow-plan` のように
skill 名を指定するか、自然文で skill 名を含めて依頼します。

## 基本フロー

1. `dynamic-workflow-plan` で scope、worker task、検証観点を決めます。
2. `dynamic-workflow-run` で read-only の subagent fan-out を実行します。
3. `dynamic-workflow-review` で findings を統合し、反証とリスクを整理します。
4. `dynamic-workflow-status` で完了、未検証範囲、次アクションを共有します。

一括で実行したい場合は `dynamic-workflow-orchestrate` を使います。ただし、
write-heavy な実装や修正は別 step として明示承認してから行います。

## よく使う依頼例

大きな作業を始める前に計画だけ作る場合:

```text
$dynamic-workflow-plan
この repo の release readiness を調査する計画を作ってください。
read-only phase と write phase を分け、worker task、検証、リスク、
未確認事項を日本語で整理してください。
```

read-only fan-out を実行する場合:

```text
$dynamic-workflow-run
この repo の release readiness を 3 つの read-only subagents に分けて
調査してください。Security、Test/Build、Documentation の観点で spawn し、
全員の完了を待ってから日本語で統合してください。ファイルは変更しないでください。
```

計画から統合まで一括で実行する場合:

```text
$dynamic-workflow-orchestrate
この repo の release readiness を Codex-native Dynamic Workflow として
3 つの read-only subagents に分けて spawn し、全員の完了を待ってから
adversarial review を行い、最終結果を日本語で統合してください。
```

複数 worker の出力をレビューする場合:

```text
$dynamic-workflow-review
以下の worker findings を統合し、重複、反証、severity、missing evidence、
security concerns、recommended action を日本語で整理してください。
```

途中状況を短く共有する場合:

```text
$dynamic-workflow-status
現在の workflow 状況を、完了、検証結果、未完了、リスク、次アクションに
分けて日本語で要約してください。
```

## 利用時の注意

- subagents は明示的に依頼された場合だけ使います。
- subagent が使えない surface では sequential checklist に fallback します。
- secrets、`.env`、認証情報、個人情報を prompt や evidence に含めないでください。
- 広い repo 調査では、まず 2 から 5 worker の小さい scope で始めてください。
- 実装、削除、依存追加、外部 API 利用は read-only 調査とは別 step にしてください。

## Security Boundary

- secrets、`.env`、認証情報、個人情報を収集または出力しません。
- 外部 API、MCP server、ChatGPT App、Docker image、GitHub Actions は初期 scope 外です。
- write phase は read-only の調査や review とは分離します。

## 公式ドキュメント根拠

- Codex manual `Plugins`: CLI は `/plugins` で plugin browser を開き、install、
  uninstall、enabled state の切り替えを行う。
- Codex manual `Build plugins`: repo-scoped marketplace は
  `$REPO_ROOT/.agents/plugins/marketplace.json` を使い、`source.path` は
  marketplace root からの `./` 始まり相対 path にする。
- Codex manual `Agent Skills`: skills は Codex CLI、IDE extension、Codex app で利用できる。
- Codex manual `Subagents`: Codex は明示的に依頼された場合に subagents を spawn し、
  結果を待って統合できる。
