import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/screens/period_master_screen.dart';
import 'package:tabulist/providers/period_master_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPeriodMasterProvider extends Mock implements PeriodMasterProvider {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockPeriodMasterProvider mockProvider;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockProvider = MockPeriodMasterProvider();
  });

  testWidgets('should display period master screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    expect(find.text('時限マスター'), findsOneWidget);
    expect(find.text('開始時刻'), findsOneWidget);
    expect(find.text('授業時間'), findsOneWidget);
    expect(find.text('休憩時間'), findsOneWidget);
    expect(find.text('テンプレート生成'), findsOneWidget);
  });

  testWidgets('should show time picker when start time is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.text('開始時刻'));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('should add class duration when add button is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('should remove class duration when remove button is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('should show confirmation dialog when generating template with existing data',
      (WidgetTester tester) async {
    when(mockProvider.periodMasters).thenReturn([
      PeriodMaster(
        id: '1',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        periods: [
          Period(
            id: '1',
            periodNumber: 1,
            duration: 45,
            isEnabled: true,
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.text('テンプレート生成'));
    await tester.pumpAndSettle();

    expect(find.text('既存の時限マスターが存在します。上書きしますか？'), findsOneWidget);
    expect(find.text('はい'), findsOneWidget);
    expect(find.text('いいえ'), findsOneWidget);
  });

  testWidgets('should show success message after generating template',
      (WidgetTester tester) async {
    when(mockProvider.generateTemplateForAllWeekdays(any, any, any))
        .thenAnswer((_) => null);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.text('テンプレート生成'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(find.text('時限マスターの設定が完了しました'), findsOneWidget);
  });

  testWidgets('should navigate to home screen after generating template',
      (WidgetTester tester) async {
    when(mockProvider.generateTemplateForAllWeekdays(any, any, any))
        .thenAnswer((_) => null);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PeriodMasterProvider>.value(
          value: mockProvider,
          child: const PeriodMasterScreen(),
        ),
      ),
    );

    await tester.tap(find.text('テンプレート生成'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
} 