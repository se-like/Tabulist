import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/screens/timetable_screen.dart';
import 'package:mockito/annotations.dart';
import 'timetable_screen_test.mocks.dart';

@GenerateMocks([MasterDataProvider, TimetableProvider])

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

    when(() => mockTimetableProvider.classes).thenReturn([
      Class(
        id: '1',
        subjectId: '1',
        teacherId: '1',
        roomId: '1',
        startTime: 9,
        endTime: 10,
        dayOfWeek: 1,
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
        memo: 'テストメモ2',
      ),
    ]);
  });

  testWidgets('時間割画面が正しく表示される', (WidgetTester tester) async {
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
          home: TimetableScreen(),
        ),
      ),
    );

    expect(find.text('時間割'), findsOneWidget);
    expect(find.text('月曜日'), findsOneWidget);
    expect(find.text('火曜日'), findsOneWidget);
    expect(find.text('水曜日'), findsOneWidget);
    expect(find.text('木曜日'), findsOneWidget);
    expect(find.text('金曜日'), findsOneWidget);
    expect(find.text('土曜日'), findsOneWidget);
    expect(find.text('日曜日'), findsOneWidget);
  });

  testWidgets('授業が正しく表示される', (WidgetTester tester) async {
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
          home: TimetableScreen(),
        ),
      ),
    );

    expect(find.text('数学'), findsOneWidget);
    expect(find.text('英語'), findsOneWidget);
    expect(find.text('山田先生'), findsOneWidget);
    expect(find.text('鈴木先生'), findsOneWidget);
    expect(find.text('101教室'), findsOneWidget);
    expect(find.text('202教室'), findsOneWidget);
  });

  testWidgets('授業をタップすると詳細が表示される', (WidgetTester tester) async {
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
          home: TimetableScreen(),
        ),
      ),
    );

    await tester.tap(find.text('数学'));
    await tester.pumpAndSettle();

    expect(find.text('授業詳細'), findsOneWidget);
    expect(find.text('科目: 数学'), findsOneWidget);
    expect(find.text('教員: 山田先生'), findsOneWidget);
    expect(find.text('教室: 101教室'), findsOneWidget);
    expect(find.text('時間: 9:00 - 10:00'), findsOneWidget);
    expect(find.text('メモ: テストメモ1'), findsOneWidget);
  });

  testWidgets('授業を長押しすると編集メニューが表示される', (WidgetTester tester) async {
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
          home: TimetableScreen(),
        ),
      ),
    );

    await tester.longPress(find.text('数学'));
    await tester.pumpAndSettle();

    expect(find.text('編集'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
  });
} 