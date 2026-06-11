#!/bin/sh
set -e

# web/ scaffolding がなければ flutter create で生成し、lib/main.dart を復元する
if [ ! -d "web" ]; then
  echo "Flutter web scaffolding を初期化中..."
  cp lib/main.dart /tmp/main.dart.bak
  flutter create --platforms=web --no-pub .
  cp /tmp/main.dart.bak lib/main.dart
  echo "初期化完了"
fi

echo "依存関係をインストール中..."
flutter pub get

echo ""
echo "======================================"
echo " ブラウザで開いてください："
echo " http://localhost:8080"
echo "======================================"
echo ""

flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --profile
