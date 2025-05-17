import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'home_screen_test.mocks.dart';

@GenerateMocks([TimetableProvider, MasterDataProvider])
void main() {
  late MockTimetableProvider mockTimetableProvider;
  late MockMasterDataProvider mockMasterDataProvider;

  setUp(() {
    mockTimetableProvider = MockTimetableProvider();
    mockMasterDataProvider = MockMasterDataProvider();

    when(mockTimetableProvider.getClassesForDay(any)).thenReturn([
      Class(
        id: '1',
        name: '数学',
        subjectId: 'sub1',
        teacherId: 't1',
        roomId: 'r1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
      ),
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
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('時間割画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Tabulist'), findsOneWidget);
    expect(find.text('数学'), findsOneWidget);
    expect(find.text('山田先生 - 101教室'), findsOneWidget);
  });

  testWidgets('授業追加ボタンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('曜日選択が正しく動作する', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 火曜日を選択
    await tester.tap(find.text('火'));
    await tester.pumpAndSettle();

    verify(mockTimetableProvider.getClassesForDay(2)).called(1);
  });
} 