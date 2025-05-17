import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/home_screen.dart';
import 'package:tabulist/screens/add_class_screen.dart';
import 'package:tabulist/screens/class_detail_screen.dart';

void main() {
  late TimetableProvider timetableProvider;
  late MasterDataProvider masterDataProvider;

  setUp(() {
    timetableProvider = TimetableProvider();
    masterDataProvider = MasterDataProvider();

    // テスト用のマスターデータを追加
    masterDataProvider.addSubject(Subject(id: 'sub1', name: '数学'));
    masterDataProvider.addTeacher(Teacher(id: 't1', name: '山田先生'));
    masterDataProvider.addRoom(Room(id: 'r1', name: '101教室'));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<TimetableProvider>.value(value: timetableProvider),
          ChangeNotifierProvider<MasterDataProvider>.value(value: masterDataProvider),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('時間割機能の統合テスト', () {
    testWidgets('授業の追加から表示、編集、削除までの一連の流れ', (WidgetTester tester) async {
      // ホーム画面を表示
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 授業追加画面を開く
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

      // 保存
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // ホーム画面に戻り、追加した授業が表示されていることを確認
      expect(find.text('数学I'), findsOneWidget);

      // 授業詳細画面を開く
      await tester.tap(find.text('数学I'));
      await tester.pumpAndSettle();

      // 編集画面を開く
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // 授業名を編集
      await tester.enterText(find.byType(TextFormField).first, '数学I（改訂版）');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 編集が反映されていることを確認
      expect(find.text('数学I（改訂版）'), findsOneWidget);

      // 削除
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除が反映されていることを確認
      expect(find.text('数学I（改訂版）'), findsNothing);
    });

    testWidgets('複数の授業の追加と表示', (WidgetTester tester) async {
      // ホーム画面を表示
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1つ目の授業を追加
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

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

      // 2つ目の授業を追加
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '数学II');
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
      await tester.tap(find.text('2限'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('曜日'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('月曜日'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 両方の授業が表示されていることを確認
      expect(find.text('数学I'), findsOneWidget);
      expect(find.text('数学II'), findsOneWidget);
    });
  });
} 