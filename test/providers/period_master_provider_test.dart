import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabulist/providers/period_master_provider.dart';
import 'package:tabulist/models/period_master.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late PeriodMasterProvider provider;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    provider = PeriodMasterProvider(prefs: mockPrefs);
  });

  group('PeriodMasterProvider', () {
    test('should initialize with empty period masters', () {
      expect(provider.periodMasters, isEmpty);
    });

    test('should add period master', () {
      final periodMaster = PeriodMaster(
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
      );

      provider.addPeriodMaster(periodMaster);

      expect(provider.periodMasters.length, 1);
      expect(provider.periodMasters.first.id, periodMaster.id);
    });

    test('should update period master', () {
      final periodMaster = PeriodMaster(
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
      );

      provider.addPeriodMaster(periodMaster);

      final updatedPeriodMaster = PeriodMaster(
        id: '1',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        periods: [
          Period(
            id: '1',
            periodNumber: 1,
            duration: 50,
            isEnabled: true,
          ),
        ],
      );

      provider.updatePeriodMaster(updatedPeriodMaster);

      expect(provider.periodMasters.length, 1);
      expect(provider.periodMasters.first.startTime.hour, 10);
      expect(provider.periodMasters.first.periods.first.duration, 50);
    });

    test('should delete period master', () {
      final periodMaster = PeriodMaster(
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
      );

      provider.addPeriodMaster(periodMaster);
      provider.deletePeriodMaster('1');

      expect(provider.periodMasters, isEmpty);
    });

    test('should get period master by day of week', () {
      final periodMaster = PeriodMaster(
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
      );

      provider.addPeriodMaster(periodMaster);

      final result = provider.getPeriodMasterByDay(1);
      expect(result, isNotNull);
      expect(result!.id, periodMaster.id);
    });

    test('should generate template for all weekdays', () {
      final startTime = const TimeOfDay(hour: 9, minute: 0);
      final classDuration = 45;
      final breakDuration = 10;

      provider.generateTemplateForAllWeekdays(startTime, classDuration, breakDuration);

      expect(provider.periodMasters.length, 5); // 月〜金
      for (var i = 1; i <= 5; i++) {
        final periodMaster = provider.getPeriodMasterByDay(i);
        expect(periodMaster, isNotNull);
        expect(periodMaster!.startTime, startTime);
        expect(periodMaster.periods.length, 6);
        expect(periodMaster.periods.first.duration, classDuration);
        expect(periodMaster.periods.first.isEnabled, true);
      }
    });

    test('should overwrite existing period masters when generating template', () {
      // 既存のデータを追加
      final existingPeriodMaster = PeriodMaster(
        id: '1',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        periods: [
          Period(
            id: '1',
            periodNumber: 1,
            duration: 40,
            isEnabled: true,
          ),
        ],
      );
      provider.addPeriodMaster(existingPeriodMaster);

      // テンプレートを生成
      final startTime = const TimeOfDay(hour: 9, minute: 0);
      final classDuration = 45;
      final breakDuration = 10;
      provider.generateTemplateForAllWeekdays(startTime, classDuration, breakDuration);

      // 既存のデータが上書きされていることを確認
      final updatedPeriodMaster = provider.getPeriodMasterByDay(1);
      expect(updatedPeriodMaster, isNotNull);
      expect(updatedPeriodMaster!.startTime, startTime);
      expect(updatedPeriodMaster.periods.length, 6);
      expect(updatedPeriodMaster.periods.first.duration, classDuration);
    });
  });
} 