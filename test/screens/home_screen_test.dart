import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/providers/period_master_provider.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/home_screen.dart';

@GenerateMocks([TimetableProvider, PeriodMasterProvider, MasterDataProvider])
import 'home_screen_test.mocks.dart';

void main() {
  late MockTimetableProvider mockTimetableProvider;
  late MockPeriodMasterProvider mockPeriodMasterProvider;
  late MockMasterDataProvider mockMasterDataProvider;

  setUp(() {
    mockTimetableProvider = MockTimetableProvider();
    mockPeriodMasterProvider = MockPeriodMasterProvider();
    mockMasterDataProvider = MockMasterDataProvider();

    when(mockTimetableProvider.isInitialized).thenReturn(true);
    when(mockPeriodMasterProvider.isInitialized).thenReturn(true);
    when(mockMasterDataProvider.isInitialized).thenReturn(true);
  });

  testWidgets('初期表示時に現在の曜日が選択されていること', (WidgetTester tester) async {
    // 現在の曜日を取得（1-7、月曜日が1）
    final currentWeekday = DateTime.now().weekday;
    // インデックスに変換（0-6、月曜日が0）
    final expectedIndex = currentWeekday - 1;

    // テスト用のウィジェットを構築
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TimetableProvider>.value(value: mockTimetableProvider),
            ChangeNotifierProvider<PeriodMasterProvider>.value(value: mockPeriodMasterProvider),
            ChangeNotifierProvider<MasterDataProvider>.value(value: mockMasterDataProvider),
          ],
          child: const HomeScreen(),
        ),
      ),
    );

    // 初期表示を待機
    await tester.pumpAndSettle();

    // 曜日セレクターの選択状態を確認
    final daySelector = find.byType(GestureDetector);
    expect(daySelector, findsNWidgets(7)); // 7つの曜日ボタンがあることを確認

    // 選択されている曜日のインデックスを確認
    final selectedDay = tester.widget<GestureDetector>(
      find.byType(GestureDetector).at(expectedIndex)
    );
    expect(selectedDay, isNotNull);
  });
} 