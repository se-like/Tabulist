import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/models/period_master.dart';

void main() {
  group('PeriodMaster', () {
    test('should create a period master with correct values', () {
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

      expect(periodMaster.id, '1');
      expect(periodMaster.dayOfWeek, 1);
      expect(periodMaster.startTime.hour, 9);
      expect(periodMaster.startTime.minute, 0);
      expect(periodMaster.periods.length, 1);
      expect(periodMaster.periods.first.periodNumber, 1);
      expect(periodMaster.periods.first.duration, 45);
      expect(periodMaster.periods.first.isEnabled, true);
    });

    test('should convert to and from JSON', () {
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

      final json = periodMaster.toJson();
      final fromJson = PeriodMaster.fromJson(json);

      expect(fromJson.id, periodMaster.id);
      expect(fromJson.dayOfWeek, periodMaster.dayOfWeek);
      expect(fromJson.startTime.hour, periodMaster.startTime.hour);
      expect(fromJson.startTime.minute, periodMaster.startTime.minute);
      expect(fromJson.periods.length, periodMaster.periods.length);
      expect(fromJson.periods.first.periodNumber, periodMaster.periods.first.periodNumber);
      expect(fromJson.periods.first.duration, periodMaster.periods.first.duration);
      expect(fromJson.periods.first.isEnabled, periodMaster.periods.first.isEnabled);
    });
  });

  group('Period', () {
    test('should create a period with correct values', () {
      final period = Period(
        id: '1',
        periodNumber: 1,
        duration: 45,
        isEnabled: true,
      );

      expect(period.id, '1');
      expect(period.periodNumber, 1);
      expect(period.duration, 45);
      expect(period.isEnabled, true);
    });

    test('should convert to and from JSON', () {
      final period = Period(
        id: '1',
        periodNumber: 1,
        duration: 45,
        isEnabled: true,
      );

      final json = period.toJson();
      final fromJson = Period.fromJson(json);

      expect(fromJson.id, period.id);
      expect(fromJson.periodNumber, period.periodNumber);
      expect(fromJson.duration, period.duration);
      expect(fromJson.isEnabled, period.isEnabled);
    });
  });
} 