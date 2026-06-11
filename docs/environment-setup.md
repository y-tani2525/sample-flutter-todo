# 環境構築手順

Docker + Flutter Web の開発環境を構築する手順です。

---

## 前提

- Docker Desktop がインストール済みであること
- ブラウザ（Chrome / Safari など）があること

---

## Flutter のパッケージ管理について

Flutter は **`flutter pub`** でパッケージを管理します。React Native の yarn に相当する操作は以下の通りです。

| React Native (yarn)               | Flutter (pub)                          |
|-----------------------------------|----------------------------------------|
| `yarn install`                    | `flutter pub get`                      |
| `yarn add <package>`              | `flutter pub add <package>`            |
| `yarn remove <package>`           | `flutter pub remove <package>`         |
| `package.json`                    | `pubspec.yaml`                         |
| `yarn.lock`                       | `pubspec.lock`                         |

パッケージの追加はコンテナ内で行います（後述）。

---

## ディレクトリ構成

```
sample-flutter-todo/
├── app/                    # Flutterアプリ本体
│   ├── lib/
│   │   └── main.dart       # エントリポイント（Cupertinoウィジェット使用）
│   ├── web/                # 初回起動時に自動生成される
│   ├── start.sh            # コンテナ起動スクリプト
│   ├── pubspec.yaml        # パッケージ設定（package.json 相当）
│   └── analysis_options.yaml
├── docs/
├── .gitignore
├── Dockerfile
└── docker-compose.yml
```

---

## 手順

### 1. イメージのビルド

```bash
docker compose build
```

> Flutter SDK を git clone するため、初回ビルドは数分かかります。

### 2. 開発サーバーの起動

```bash
docker compose up
```

初回起動時のみ `flutter create` による web/ スキャフォールドの生成と `flutter pub get` が実行されます。

起動後、以下のようなメッセージが表示されます：

```
======================================
 ブラウザで開いてください：
 http://localhost:8080
======================================
```

### 3. ブラウザで確認

`http://localhost:8080` を開くと Todo アプリが表示されます。

### 4. ホットリロード

コンテナが起動している状態で、`app/lib/main.dart` を編集すると自動でリロードされます。
ターミナルで `r` を押すと手動でホットリロードできます。

---

## パッケージの追加方法

```bash
docker compose run --rm app flutter pub add <package-name>
```

例：

```bash
docker compose run --rm app flutter pub add shared_preferences
```

---

## 詰まりやすいポイント

### flutter pub get が失敗する

コンテナを再作成後に `pubspec.lock` と `.dart_tool/` が残っている場合、バージョンが合わずに失敗することがあります。

**対処**:

```bash
rm -rf app/.dart_tool app/pubspec.lock
docker compose up
```

---

### web/ ディレクトリが生成されない

`start.sh` の実行権限がない場合に発生します。

**対処**:

```bash
chmod +x app/start.sh
docker compose up
```

---

### ポートが使用中

```
Error starting userland proxy: listen tcp4 0.0.0.0:8080: bind: address already in use
```

**対処**: `docker ps` で確認し、`docker-compose.yml` のホスト側ポートを空き番号に変更します。
`start.sh` の `--web-port` も同じ番号に合わせてください。

---

### hot reload が効かない

`flutter run` は `stdin_open: true` と `tty: true` が必要です。`docker compose up` で起動した場合は有効です。
`docker compose up -d`（バックグラウンド起動）では hot reload のターミナル操作ができません。

---

## 停止

```bash
docker compose down
```
