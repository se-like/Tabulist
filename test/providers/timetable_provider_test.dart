import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/providers/timetable_provider.dart';
import 'package:tabulist/models/class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SharedPreferences])
import 'timetable_provider_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TimetableProvider provider;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    provider = TimetableProvider(prefs: mockPrefs);
  });

  group('TimetableProvider Tests', () {
    test('should get classes for specific day', () {
      final classes = [
        Class(
          id: '1',
          name: '数学',
          subjectId: 'sub1',
          teacherId: 'tea1',
          roomId: 'room1',
          startTime: 540,
          endTime: 630,
          dayOfWeek: 1, // 月曜日
        ),
        Class(
          id: '2',
          name: '英語',
          subjectId: 'sub2',
          teacherId: 'tea2',
          roomId: 'room2',
          startTime: 630,
          endTime: 720,
          dayOfWeek: 2, // 火曜日
        ),
      ];

      // テスト用のデータをセット
      provider.addClass(classes[0], prefs: mockPrefs);
      provider.addClass(classes[1], prefs: mockPrefs);

      // 月曜日の授業を取得
      final mondayClasses = provider.getClassesForDay(1);
      expect(mondayClasses.length, 1);
      expect(mondayClasses[0].name, '数学');

      // 火曜日の授業を取得
      final tuesdayClasses = provider.getClassesForDay(2);
      expect(tuesdayClasses.length, 1);
      expect(tuesdayClasses[0].name, '英語');

      // 水曜日の授業を取得（存在しない）
      final wednesdayClasses = provider.getClassesForDay(3);
      expect(wednesdayClasses.length, 0);
    });

    test('should add and save class', () {
      final classItem = Class(
        id: '1',
        name: '数学',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
      );

      provider.addClass(classItem, prefs: mockPrefs);
      expect(provider.classes.length, 1);
      expect(provider.classes[0].name, '数学');
    });

    test('should update class', () {
      final classItem = Class(
        id: '1',
        name: '数学',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
      );

      provider.addClass(classItem, prefs: mockPrefs);

      final updatedClass = Class(
        id: '1',
        name: '数学（更新）',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
      );

      provider.updateClass(updatedClass, prefs: mockPrefs);
      expect(provider.classes.length, 1);
      expect(provider.classes[0].name, '数学（更新）');
    });

    test('should delete class', () {
      final classItem = Class(
        id: '1',
        name: '数学',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
      );

      provider.addClass(classItem, prefs: mockPrefs);
      expect(provider.classes.length, 1);

      provider.deleteClass('1', prefs: mockPrefs);
      expect(provider.classes.length, 0);
    });
  });
} 