# トラブルシューティング

環境構築・開発中に実際に発生したエラーと対処法をまとめたものです。

---

## Divider が使えない（InvalidType エラー）

### 症状

```
lib/main.dart:110:58: Error: Not a constant expression.
                      separatorBuilder: (_, __) => const Divider(
                                                         ^^^^^^^
Unhandled exception:
Unsupported operation: Unsupported invalid type InvalidType(<invalid>)
```

### 原因

`Divider` は `package:flutter/material.dart` のウィジェットで、`package:flutter/cupertino.dart` には含まれていない。
Cupertino のみのアプリで `Divider` を使うとコンパイラが型を解決できず InvalidType エラーになる。

### 対処

`Divider` を `Container` + `CupertinoColors.separator` で代替する。

```dart
// NG
separatorBuilder: (_, __) => const Divider(
  height: 1,
  indent: 16,
  endIndent: 16,
),

// OK
separatorBuilder: (_, __) => Container(
  height: 0.5,
  margin: const EdgeInsets.symmetric(horizontal: 16),
  color: CupertinoColors.separator,
),
```

---

## 画面が真っ白になる（DWDS injected client エラー）

### 症状

ブラウザで `http://localhost:8080` を開くと白画面のまま、コンソールに以下が出る。

```
Unhandled error detected in the injected client.js script.
TypeError: Instance of '_JsonMap': type '_JsonMap' is not a subtype of type 'List<Object?>'
    at Rti._generalAsCheckImplementation [as _as] (http://localhost:8080/dwds/src/injected/client.js:...)
    ...
```

### 原因

Flutter web のデバッグ用ツール DWDS（Dart Web Dev Service）が注入する `client.js` に型不一致のバグがある。
特定の Flutter stable バージョンで発生する既知の問題で、DWDS クライアントがアプリの初期化をブロックするため白画面になる。

### 試みた対処（失敗）

エラーメッセージに `--no-injected-client` フラグが記載されているが、`flutter run` には存在しないフラグのためエラーになる。

```
Could not find an option named "--no-injected-client".
```

### 対処

`--profile` モードで起動する。profile モードは DWDS クライアントを注入しないため白画面にならない。

**`app/start.sh`**

```sh
# NG（デバッグモード、DWDS が白画面を引き起こす）
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

# OK（profile モード、DWDS なし）
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --profile
```

**注意**: `--profile` モードではホットリロードが使えない。コードを変更した場合は `docker compose restart` で再起動する。
