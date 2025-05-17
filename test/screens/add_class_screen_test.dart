import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/class_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/add_class_screen.dart';
import 'package:mockito/annotations.dart';
import 'add_class_screen_test.mocks.dart';

@GenerateMocks([ClassProvider, MasterDataProvider])

void main() {
  late MockMasterDataProvider mockMasterDataProvider;
  late MockTimetableProvider mockTimetableProvider;

  setUp(() {
    mockMasterDataProvider = MockMasterDataProvider();
    mockTimetableProvider = MockTimetableProvider();

    when(() => mockMasterDataProvider.subjects).thenReturn([
      Subject(id: '1', name: '数学'),
      Subject(id: '2', name: '英語'),
    ]);
    when(() => mockMasterDataProvider.teachers).thenReturn([
      Teacher(id: '1', name: '山田先生'),
      Teacher(id: '2', name: '鈴木先生'),
    ]);
    when(() => mockMasterDataProvider.rooms).thenReturn([
      Room(id: '1', name: '101教室'),
      Room(id: '2', name: '202教室'),
    ]);
  });

  testWidgets('授業追加画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(
            value: mockMasterDataProvider,
          ),
          ChangeNotifierProvider<TimetableProvider>.value(
            value: mockTimetableProvider,
          ),
        ],
        child: const MaterialApp(
          home: AddClassScreen(),
        ),
      ),
    );

    expect(find.text('授業を追加'), findsOneWidget);
    expect(find.text('科目'), findsOneWidget);
    expect(find.text('教員'), findsOneWidget);
    expect(find.text('教室'), findsOneWidget);
    expect(find.text('曜日'), findsOneWidget);
    expect(find.text('開始時間'), findsOneWidget);
    expect(find.text('終了時間'), findsOneWidget);
    expect(find.text('メモ'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('必須項目が入力されていない場合、エラーメッセージが表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(
            value: mockMasterDataProvider,
          ),
          ChangeNotifierProvider<TimetableProvider>.value(
            value: mockTimetableProvider,
          ),
        ],
        child: const MaterialApp(
          home: AddClassScreen(),
        ),
      ),
    );

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('科目を選択してください'), findsOneWidget);
    expect(find.text('教員を選択してください'), findsOneWidget);
    expect(find.text('教室を選択してください'), findsOneWidget);
    expect(find.text('曜日を選択してください'), findsOneWidget);
    expect(find.text('開始時間を選択してください'), findsOneWidget);
    expect(find.text('終了時間を選択してください'), findsOneWidget);
  });

  testWidgets('全ての項目を入力して保存できる', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(
            value: mockMasterDataProvider,
          ),
          ChangeNotifierProvider<TimetableProvider>.value(
            value: mockTimetableProvider,
          ),
        ],
        child: const MaterialApp(
          home: AddClassScreen(),
        ),
      ),
    );

    // 科目を選択
    await tester.tap(find.text('科目'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('数学'));
    await tester.pumpAndSettle();

    // 教員を選択
    await tester.tap(find.text('教員'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('山田先生'));
    await tester.pumpAndSettle();

    // 教室を選択
    await tester.tap(find.text('教室'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('101教室'));
    await tester.pumpAndSettle();

    // 曜日を選択
    await tester.tap(find.text('曜日'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('月曜日'));
    await tester.pumpAndSettle();

    // 開始時間を選択
    await tester.tap(find.text('開始時間'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('9時'));
    await tester.pumpAndSettle();

    // 終了時間を選択
    await tester.tap(find.text('終了時間'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10時'));
    await tester.pumpAndSettle();

    // メモを入力
    await tester.enterText(find.byType(TextFormField).last, 'テストメモ');
    await tester.pumpAndSettle();

    // 保存ボタンをタップ
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    verify(
      () => mockTimetableProvider.addClass(
        any(
          that: predicate(
            (Class c) =>
                c.subjectId == '1' &&
                c.teacherId == '1' &&
                c.roomId == '1' &&
                c.dayOfWeek == 1 &&
                c.startTime == 9 &&
                c.endTime == 10 &&
                c.memo == 'テストメモ',
          ),
        ),
      ),
    ).called(1);
  });
} 