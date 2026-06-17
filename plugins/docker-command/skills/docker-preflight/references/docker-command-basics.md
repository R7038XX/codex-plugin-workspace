# docker command basics

## docker version
- いつ使う: daemon 利用可否の確認
- いつ使わない: 日常的な差分比較用途
- 分類: 条件付き実行
- 出力の見方: client/server version と API バージョン
- 失敗時参照: common-failures.md

## docker context show
- いつ使う: 現在 context を確認
- いつ使わない: context 変更が不要な場面
- 分類: 自動実行可
- 出力の見方: context 名を確認
- 失敗時参照: common-failures.md

## docker ps
- いつ使う: 稼働 container と状態把握
- いつ使わない: 大量運用環境の逐次監視
- 分類: 自動実行可
- 出力の見方: STATUS と NAMES
- 失敗時参照: common-failures.md

## docker system df
- いつ使う: disk 使用量・キャッシュ確認
- いつ使わない: 大量ノイズ時の定常監視
- 分類: 自動実行可
- 出力の見方: Images, Containers, Local Volumes, Build Cache
- 失敗時参照: common-failures.md

## docker compose version
- いつ使う: compose 利用可否確認
- いつ使わない: compose を使わないワークフロー
- 分類: 自動実行可
- 出力の見方: compose plugin/binary バージョン
- 失敗時参照: common-failures.md

## docker compose ps
- いつ使う: compose 管理サービス状態の確認
- いつ使わない: 実体が compose でない場合
- 分類: 条件付き実行
- 出力の見方: service/state/ports
- 失敗時参照: common-failures.md

## docker compose logs
- いつ使う: 障害時の一次調査
- いつ使わない: 平常時の頻繁な取得
- 分類: 条件付き実行
- 出力の見方: 最後尾の error/warn
- 失敗時参照: common-failures.md

## docker compose build
- いつ使う: ビルド実行前の主要処理
- いつ使わない: context/seed が不正な場合
- 分類: 条件付き実行
- 出力の見方: Image 作成ステータス
- 失敗時参照: common-failures.md

## docker compose run --rm
- いつ使う: テスト系コマンド実行
- いつ使わない: サービス起動前提の長時間処理
- 分類: 条件付き実行
- 出力の見方: テスト結果 exit code
- 失敗時参照: common-failures.md

## docker compose up -d
- いつ使う: テスト・検証前の起動
- いつ使わない: host 側依存が強い検証前提
- 分類: 条件付き実行
- 出力の見方: 起動ログと service 停止有無
- 失敗時参照: common-failures.md

## docker compose exec -T
- いつ使う: container 内 smoke test
- いつ使わない: host の localhost にのみ依存する場合
- 分類: 条件付き実行
- 出力の見方: command exit code と stderr
- 失敗時参照: common-failures.md

## docker container prune -f
- いつ使う: cleanup で未使用コンテナ削除
- いつ使わない: 本番前提データ保持が必要な場面
- 分類: 条件付き実行
- 出力の見方: Removed の件数
- 失敗時参照: cleanup-policy.md

## docker image prune -f
- いつ使う: 未使用 image cleanup
- いつ使わない: 再デプロイ短時間で直近 image が必要な場面
- 分類: 条件付き実行
- 出力の見方: Deleted image 数
- 失敗時参照: cleanup-policy.md

## docker builder prune -f
- いつ使う: builder cache クリーンアップ
- いつ使わない: build 再実行最適化を最大化したい直前
- 分類: 条件付き実行
- 出力の見方: Reclaimed space
- 失敗時参照: cleanup-policy.md

## docker network prune -f
- いつ使う: 未使用 network の整理
- いつ使わない: compose 外部ネットワーク再利用が必要な時
- 分類: 条件付き実行
- 出力の見方: Removed network 数
- 失敗時参照: cleanup-policy.md
