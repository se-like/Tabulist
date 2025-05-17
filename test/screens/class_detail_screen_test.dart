import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/class_detail_screen.dart';
import 'package:mockito/annotations.dart';
import 'class_detail_screen_test.mocks.dart';

@GenerateMocks([TimetableProvider, MasterDataProvider])
void main() {
  late MockTimetableProvider mockTimetableProvider;
  late MockMasterDataProvider mockMasterDataProvider;
  late Class testClass;

  setUp(() {
    mockTimetableProvider = MockTimetableProvider();
    mockMasterDataProvider = MockMasterDataProvider();

    testClass = Class(
      id: '1',
      name: '数学',
      subjectId: 'sub1',
      teacherId: 't1',
      roomId: 'r1',
      startTime: 540,
      endTime: 630,
      dayOfWeek: 1,
      memo: 'テストメモ',
    );

    when(mockMasterDataProvider.subjects).thenReturn([
      Subject(id: 'sub1', name: '数学'),
    ]);
    when(mockMasterDataProvider.teachers).thenReturn([
      Teacher(id: 't1', name: '山田先生'),
    ]);
    when(mockMasterDataProvider.rooms).thenReturn([
      Room(id: 'r1', name: '101教室'),
    ]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<TimetableProvider>.value(value: mockTimetableProvider),
          ChangeNotifierProvider<MasterDataProvider>.value(value: mockMasterDataProvider),
        ],
        child: ClassDetailScreen(classItem: testClass),
      ),
    );
  }

  testWidgets('授業詳細画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('数学'), findsOneWidget);
    expect(find.text('山田先生'), findsOneWidget);
    expect(find.text('101教室'), findsOneWidget);
    expect(find.text('テストメモ'), findsOneWidget);
  });

  testWidgets('編集ボタンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('削除ボタンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('削除確認ダイアログが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('授業を削除'), findsOneWidget);
    expect(find.text('この授業を削除してもよろしいですか？'), findsOneWidget);
  });

  testWidgets('削除が正しく実行される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    verify(mockTimetableProvider.deleteClass('1')).called(1);
  });
} 