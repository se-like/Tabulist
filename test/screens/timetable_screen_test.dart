import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/timetable_screen.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'timetable_screen_test.mocks.dart';

@GenerateMocks([TimetableProvider, MasterDataProvider])

void main() {
  late MockTimetableProvider mockTimetableProvider;
  late MockMasterDataProvider mockMasterDataProvider;

  setUp(() {
    mockTimetableProvider = MockTimetableProvider();
    mockMasterDataProvider = MockMasterDataProvider();

    when(mockMasterDataProvider.subjects).thenReturn([
      Subject(id: '1', name: '数学'),
      Subject(id: '2', name: '英語'),
    ]);
    when(mockMasterDataProvider.teachers).thenReturn([
      Teacher(id: '1', name: '山田先生'),
      Teacher(id: '2', name: '鈴木先生'),
    ]);
    when(mockMasterDataProvider.rooms).thenReturn([
      Room(id: '1', name: '101教室'),
      Room(id: '2', name: '202教室'),
    ]);
    when(mockTimetableProvider.classes).thenReturn([
      Class(
        id: '1',
        subjectId: '1',
        teacherId: '1',
        roomId: '1',
        startTime: 9,
        endTime: 10,
        dayOfWeek: 1,
        periodNumber: 1,
        memo: 'テストメモ1',
      ),
      Class(
        id: '2',
        subjectId: '2',
        teacherId: '2',
        roomId: '2',
        startTime: 10,
        endTime: 11,
        dayOfWeek: 2,
        periodNumber: 2,
      ),
    ]);
    when(mockTimetableProvider.getClassesForDay(any)).thenAnswer((invocation) {
      final day = invocation.positionalArguments[0];
      return mockTimetableProvider.classes.where((c) => c.dayOfWeek == day).toList();
    });
  });

  testWidgets('時間割画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TimetableProvider>.value(
              value: mockTimetableProvider,
            ),
            ChangeNotifierProvider<MasterDataProvider>.value(
              value: mockMasterDataProvider,
            ),
          ],
          child: const TimetableScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 月曜日のタブをタップ
    await tester.tap(find.text('月曜日'));
    await tester.pumpAndSettle();

    // 授業が正しく表示されていることを確認
    expect(find.text('数学'), findsOneWidget);
    expect(find.text('山田先生 / 101教室'), findsOneWidget);
  });

  testWidgets('授業をタップすると詳細が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TimetableProvider>.value(
              value: mockTimetableProvider,
            ),
            ChangeNotifierProvider<MasterDataProvider>.value(
              value: mockMasterDataProvider,
            ),
          ],
          child: const TimetableScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 月曜日のタブをタップ
    await tester.tap(find.text('月曜日'));
    await tester.pumpAndSettle();

    // 授業をタップ
    await tester.tap(find.text('数学'));
    await tester.pumpAndSettle();

    // 詳細が表示されていることを確認
    expect(find.text('授業詳細'), findsOneWidget);
    expect(find.text('科目: 数学'), findsOneWidget);
    expect(find.text('教員: 山田先生'), findsOneWidget);
    expect(find.text('教室: 101教室'), findsOneWidget);
    expect(find.text('メモ: テストメモ1'), findsOneWidget);
  });

  testWidgets('授業を長押しすると編集メニューが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TimetableProvider>.value(
              value: mockTimetableProvider,
            ),
            ChangeNotifierProvider<MasterDataProvider>.value(
              value: mockMasterDataProvider,
            ),
          ],
          child: const TimetableScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 月曜日のタブをタップ
    await tester.tap(find.text('月曜日'));
    await tester.pumpAndSettle();

    // 授業を長押し
    await tester.longPress(find.text('数学'));
    await tester.pumpAndSettle();

    // 編集メニューが表示されていることを確認
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
  });
} 