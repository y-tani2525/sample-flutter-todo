# sample-flutter-todo

Docker + Flutter Web で動く Todo アプリのサンプルです。UI は Cupertino ウィジェットで実装しています。

## 起動

```bash
# 初回のみ（Flutter SDK のダウンロードで数分かかります）
docker compose build

# 起動
docker compose up
```

ブラウザで `http://localhost:8080` を開くと Todo アプリが表示されます。

## パッケージの追加

```bash
docker compose run --rm app flutter pub add <package-name>
```

## ドキュメント

- [環境構築手順](docs/environment-setup.md)
- [トラブルシューティング](docs/troubleshooting.md)
