import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/main.dart';

void main() {
  late TimetableProvider timetableProvider;
  late MasterDataProvider masterDataProvider;

  setUp(() {
    timetableProvider = TimetableProvider();
    masterDataProvider = MasterDataProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimetableProvider>.value(value: timetableProvider),
        ChangeNotifierProvider<MasterDataProvider>.value(value: masterDataProvider),
      ],
      child: const MyApp(),
    );
  }

  group('アプリケーション全体の統合テスト', () {
    testWidgets('マスターデータの追加から授業の追加までの一連の流れ', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // マスターデータ画面に移動
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 科目を追加
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '数学');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教員を追加
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '山田先生');
      await tester.enterText(find.byType(TextFormField).at(1), 'yamada@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '090-1234-5678');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教室を追加
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '101教室');
      await tester.enterText(find.byType(TextFormField).at(1), '本館');
      await tester.enterText(find.byType(TextFormField).at(2), '1');
      await tester.enterText(find.byType(TextFormField).at(3), '40');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // ホーム画面に戻る
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 授業を追加
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 授業情報を入力
      await tester.enterText(find.byType(TextFormField).first, '数学I');
      await tester.tap(find.text('科目'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('数学'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('教員'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('山田先生'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('教室'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('101教室'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('時間'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1限'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('曜日'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('月曜日'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 授業が追加されていることを確認
      expect(find.text('数学I'), findsOneWidget);

      // 授業詳細画面を開く
      await tester.tap(find.text('数学I'));
      await tester.pumpAndSettle();

      // 授業の詳細情報が正しく表示されていることを確認
      expect(find.text('数学'), findsOneWidget);
      expect(find.text('山田先生'), findsOneWidget);
      expect(find.text('101教室'), findsOneWidget);
    });

    testWidgets('マスターデータの削除による授業の影響確認', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // マスターデータ画面に移動
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 科目を追加
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '数学');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教員を追加
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '山田先生');
      await tester.enterText(find.byType(TextFormField).at(1), 'yamada@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '090-1234-5678');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教室を追加
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '101教室');
      await tester.enterText(find.byType(TextFormField).at(1), '本館');
      await tester.enterText(find.byType(TextFormField).at(2), '1');
      await tester.enterText(find.byType(TextFormField).at(3), '40');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // ホーム画面に戻る
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 授業を追加
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 授業情報を入力
      await tester.enterText(find.byType(TextFormField).first, '数学I');
      await tester.tap(find.text('科目'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('数学'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('教員'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('山田先生'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('教室'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('101教室'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('時間'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1限'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('曜日'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('月曜日'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // マスターデータ画面に戻る
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 科目を削除
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // ホーム画面に戻る
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 授業が正しく表示されていることを確認（科目名が「未設定」になっているはず）
      expect(find.text('数学I'), findsOneWidget);
      expect(find.text('未設定'), findsOneWidget);
    });
  });
} 