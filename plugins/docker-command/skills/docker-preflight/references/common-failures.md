# docker-preflight common failures

## permission denied while trying to connect to the docker API
- 種別: failure
- 代表原因: socket 権限不足
- 対応: docker group 追加または実行ユーザーの権限見直し

## Cannot connect to the Docker daemon
- 種別: failure
- 代表原因: daemon 未起動、context 不一致
- 対応: Docker サービス起動、`docker context` と endpoint の確認

## host から localhost への接続失敗
- 種別: warning
- 代表原因: sandbox 制約またはネットワーク分離
- 対応: container 内検証に切替え、`localhost` 依存を避ける

## container が存在しない
- 種別: failure
- 代表原因: service 名ミス、起動漏れ、profile 不一致
- 対応: compose service 設定と compose profile を再確認

## scanner が見つからない
- 種別: warning
- 代表原因: trivy/docker scout 未インストール
- 対応: `not_run_scanner_unavailable` を維持し、成功扱いしない
