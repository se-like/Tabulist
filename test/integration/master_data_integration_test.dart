import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/master_data_screen.dart';
import 'package:tabulist/screens/master_data_edit_screen.dart';

void main() {
  late MasterDataProvider masterDataProvider;

  setUp(() {
    masterDataProvider = MasterDataProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(value: masterDataProvider),
        ],
        child: const MasterDataScreen(),
      ),
    );
  }

  group('マスターデータ管理機能の統合テスト', () {
    testWidgets('科目の追加から表示、編集、削除までの一連の流れ', (WidgetTester tester) async {
      // マスターデータ画面を表示
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 科目追加画面を開く
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // 科目情報を入力
      await tester.enterText(find.byType(TextFormField).first, '数学');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 科目が追加されていることを確認
      expect(find.text('数学'), findsOneWidget);

      // 科目編集画面を開く
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // 科目名を編集
      await tester.enterText(find.byType(TextFormField).first, '数学（改訂版）');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 編集が反映されていることを確認
      expect(find.text('数学（改訂版）'), findsOneWidget);

      // 削除
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除が反映されていることを確認
      expect(find.text('数学（改訂版）'), findsNothing);
    });

    testWidgets('教員の追加から表示、編集、削除までの一連の流れ', (WidgetTester tester) async {
      // マスターデータ画面を表示
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 教員追加画面を開く
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pumpAndSettle();

      // 教員情報を入力
      await tester.enterText(find.byType(TextFormField).at(0), '山田先生');
      await tester.enterText(find.byType(TextFormField).at(1), 'yamada@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '090-1234-5678');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教員が追加されていることを確認
      expect(find.text('山田先生'), findsOneWidget);

      // 教員編集画面を開く
      await tester.tap(find.byIcon(Icons.edit).at(1));
      await tester.pumpAndSettle();

      // 教員名を編集
      await tester.enterText(find.byType(TextFormField).at(0), '山田先生（改訂版）');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 編集が反映されていることを確認
      expect(find.text('山田先生（改訂版）'), findsOneWidget);

      // 削除
      await tester.tap(find.byIcon(Icons.delete).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除が反映されていることを確認
      expect(find.text('山田先生（改訂版）'), findsNothing);
    });

    testWidgets('教室の追加から表示、編集、削除までの一連の流れ', (WidgetTester tester) async {
      // マスターデータ画面を表示
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 教室追加画面を開く
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pumpAndSettle();

      // 教室情報を入力
      await tester.enterText(find.byType(TextFormField).at(0), '101教室');
      await tester.enterText(find.byType(TextFormField).at(1), '本館');
      await tester.enterText(find.byType(TextFormField).at(2), '1');
      await tester.enterText(find.byType(TextFormField).at(3), '40');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 教室が追加されていることを確認
      expect(find.text('101教室'), findsOneWidget);

      // 教室編集画面を開く
      await tester.tap(find.byIcon(Icons.edit).at(2));
      await tester.pumpAndSettle();

      // 教室名を編集
      await tester.enterText(find.byType(TextFormField).at(0), '101教室（改訂版）');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 編集が反映されていることを確認
      expect(find.text('101教室（改訂版）'), findsOneWidget);

      // 削除
      await tester.tap(find.byIcon(Icons.delete).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除が反映されていることを確認
      expect(find.text('101教室（改訂版）'), findsNothing);
    });
  });
} 