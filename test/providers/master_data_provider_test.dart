import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([SharedPreferences])
import 'master_data_provider_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late MasterDataProvider provider;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    provider = MasterDataProvider(prefs: mockPrefs);

    // SharedPreferencesのモック設定
    when(mockPrefs.getStringList(any)).thenReturn([]);
    when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
  });

  group('MasterDataProvider Tests', () {
    test('should load empty data when no saved data exists', () async {
      await provider.loadMasterData();
      expect(provider.subjects, isEmpty);
      expect(provider.teachers, isEmpty);
      expect(provider.rooms, isEmpty);
    });

    test('should add and save subject', () async {
      final subject = Subject(id: '1', name: '数学');
      await provider.addSubject(subject);
      expect(provider.subjects.length, 1);
      expect(provider.subjects[0].name, '数学');
    });

    test('should add and save teacher', () async {
      final teacher = Teacher(id: '1', name: '山田先生');
      await provider.addTeacher(teacher);
      expect(provider.teachers.length, 1);
      expect(provider.teachers[0].name, '山田先生');
    });

    test('should add and save room', () async {
      final room = Room(id: '1', name: '101教室');
      await provider.addRoom(room);
      expect(provider.rooms.length, 1);
      expect(provider.rooms[0].name, '101教室');
    });

    test('should update subject', () async {
      final subject = Subject(id: '1', name: '数学');
      await provider.addSubject(subject);

      final updatedSubject = Subject(id: '1', name: '数学（更新）');
      await provider.updateSubject(updatedSubject);
      expect(provider.subjects[0].name, '数学（更新）');
    });

    test('should update teacher', () async {
      final teacher = Teacher(id: '1', name: '山田先生');
      await provider.addTeacher(teacher);

      final updatedTeacher = Teacher(id: '1', name: '山田先生（更新）');
      await provider.updateTeacher(updatedTeacher);
      expect(provider.teachers[0].name, '山田先生（更新）');
    });

    test('should update room', () async {
      final room = Room(id: '1', name: '101教室');
      await provider.addRoom(room);

      final updatedRoom = Room(id: '1', name: '101教室（更新）');
      await provider.updateRoom(updatedRoom);
      expect(provider.rooms[0].name, '101教室（更新）');
    });

    test('should delete subject', () async {
      final subject = Subject(id: '1', name: '数学');
      await provider.addSubject(subject);
      expect(provider.subjects.length, 1);

      await provider.deleteSubject('1');
      expect(provider.subjects, isEmpty);
    });

    test('should delete teacher', () async {
      final teacher = Teacher(id: '1', name: '山田先生');
      await provider.addTeacher(teacher);
      expect(provider.teachers.length, 1);

      await provider.deleteTeacher('1');
      expect(provider.teachers, isEmpty);
    });

    test('should delete room', () async {
      final room = Room(id: '1', name: '101教室');
      await provider.addRoom(room);
      expect(provider.rooms.length, 1);

      await provider.deleteRoom('1');
      expect(provider.rooms, isEmpty);
    });
  });
} 