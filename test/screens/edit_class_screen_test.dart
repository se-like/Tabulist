import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/screens/edit_class_screen.dart';
import 'package:mockito/annotations.dart';
import 'edit_class_screen_test.mocks.dart';

@GenerateMocks([MasterDataProvider, TimetableProvider])

void main() {
  late MockMasterDataProvider mockMasterDataProvider;
  late MockTimetableProvider mockTimetableProvider;
  late Class testClass;

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

    testClass = Class(
      id: '1',
      subjectId: '1',
      teacherId: '1',
      roomId: '1',
      startTime: 9,
      endTime: 10,
      dayOfWeek: 1,
      memo: 'テストメモ',
    );
  });

  testWidgets('授業編集画面が正しく表示される', (WidgetTester tester) async {
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
        child: MaterialApp(
          home: EditClassScreen(classItem: testClass),
        ),
      ),
    );

    expect(find.text('授業を編集'), findsOneWidget);
    expect(find.text('科目'), findsOneWidget);
    expect(find.text('教員'), findsOneWidget);
    expect(find.text('教室'), findsOneWidget);
    expect(find.text('曜日'), findsOneWidget);
    expect(find.text('開始時間'), findsOneWidget);
    expect(find.text('終了時間'), findsOneWidget);
    expect(find.text('メモ'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('既存の授業情報が正しく表示される', (WidgetTester tester) async {
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
        child: MaterialApp(
          home: EditClassScreen(classItem: testClass),
        ),
      ),
    );

    expect(find.text('数学'), findsOneWidget);
    expect(find.text('山田先生'), findsOneWidget);
    expect(find.text('101教室'), findsOneWidget);
    expect(find.text('月曜日'), findsOneWidget);
    expect(find.text('9時'), findsOneWidget);
    expect(find.text('10時'), findsOneWidget);
    expect(find.text('テストメモ'), findsOneWidget);
  });

  testWidgets('授業情報を更新できる', (WidgetTester tester) async {
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
        child: MaterialApp(
          home: EditClassScreen(classItem: testClass),
        ),
      ),
    );

    // 科目を変更
    await tester.tap(find.text('科目'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英語'));
    await tester.pumpAndSettle();

    // 教員を変更
    await tester.tap(find.text('教員'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('鈴木先生'));
    await tester.pumpAndSettle();

    // 教室を変更
    await tester.tap(find.text('教室'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('202教室'));
    await tester.pumpAndSettle();

    // 曜日を変更
    await tester.tap(find.text('曜日'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('火曜日'));
    await tester.pumpAndSettle();

    // 開始時間を変更
    await tester.tap(find.text('開始時間'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10時'));
    await tester.pumpAndSettle();

    // 終了時間を変更
    await tester.tap(find.text('終了時間'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11時'));
    await tester.pumpAndSettle();

    // メモを変更
    await tester.enterText(find.byType(TextFormField).last, '更新されたメモ');
    await tester.pumpAndSettle();

    // 保存ボタンをタップ
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    verify(
      () => mockTimetableProvider.updateClass(
        any(
          that: predicate(
            (Class c) =>
                c.id == '1' &&
                c.subjectId == '2' &&
                c.teacherId == '2' &&
                c.roomId == '2' &&
                c.dayOfWeek == 2 &&
                c.startTime == 10 &&
                c.endTime == 11 &&
                c.memo == '更新されたメモ',
          ),
        ),
      ),
    ).called(1);
  });
} 