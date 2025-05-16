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

## 使用しているパッケージ

- provider: ^6.1.1 - 状態管理
- shared_preferences: ^2.2.2 - ローカルストレージ
- intl: ^0.19.0 - 国際化
- flutter_local_notifications: ^16.3.0 - 通知機能
- table_calendar: ^3.0.9 - カレンダー表示

## ライセンス

MIT License
