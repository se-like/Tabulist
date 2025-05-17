# Tabulist

学生向けの時間割管理アプリケーション

## 機能

- 週間表示での時間割管理
- 授業の追加・編集・削除
- 授業の詳細情報（教室、担当教員、メモなど）の管理
- ダークモード対応
- データの永続化（ローカルストレージ）

## 開発環境

- Flutter 3.2.3以上
- Dart SDK 3.2.3以上

## セットアップ

1. リポジトリをクローン
```bash
git clone https://github.com/se-like/Tabulist.git
```

2. 依存関係をインストール
```bash
cd Tabulist
flutter pub get
```

3. アプリを実行
```bash
flutter run
```

## ビルド

### Android APKのビルド
```bash
flutter build apk --release
```
ビルドされたAPKは`build/app/outputs/flutter-apk/app-release.apk`に出力されます。

### iOSアプリのビルド
```bash
flutter build ios --release
```
ビルドされたアプリは`build/ios/iphoneos/Runner.app`に出力されます。

## 使用しているパッケージ

- provider: ^6.1.1 - 状態管理
- shared_preferences: ^2.2.2 - ローカルストレージ
- intl: ^0.19.0 - 国際化
- flutter_local_notifications: ^16.3.0 - 通知機能
- table_calendar: ^3.0.9 - カレンダー表示

## テストの実行

### ユニットテスト
```bash
flutter test
```

### 統合テスト
```bash
flutter test integration_test
```

### テストカバレッジレポートの生成
```bash
./scripts/generate_coverage.sh
```

生成されたレポートは`coverage/html/index.html`で確認できます。

## テストカバレッジの基準

- ビジネスロジックのテストカバレッジは90%以上を維持
- UIコンポーネントは主要なユーザーインタラクションのテストを必ず含める
- 時間割のCRUD操作は100%カバレッジを目標とする

## CI/CD

GitHub Actionsで以下のチェックが自動実行されます：

1. テストの実行
2. テストカバレッジレポートの生成
3. カバレッジしきい値（90%）のチェック
4. Android APKとiOSアプリのビルド

## ライセンス

MIT License
