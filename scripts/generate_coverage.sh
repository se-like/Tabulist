#!/bin/bash

# テストカバレッジレポートを生成するディレクトリ
COVERAGE_DIR="coverage"

# テストを実行してカバレッジデータを収集
flutter test --coverage

# HTMLレポートを生成
genhtml coverage/lcov.info -o $COVERAGE_DIR/html

# カバレッジの概要を表示
echo "=== テストカバレッジの概要 ==="
lcov --summary coverage/lcov.info

# カバレッジレポートのURLを表示
echo "=== カバレッジレポート ==="
echo "HTMLレポート: file://$(pwd)/$COVERAGE_DIR/html/index.html" 