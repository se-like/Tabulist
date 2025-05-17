import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/models/class.dart';

void main() {
  group('Class Model Tests', () {
    test('should create a class with all required fields', () {
      final classItem = Class(
        id: '1',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540, // 9:00
        endTime: 630, // 10:30
        dayOfWeek: 1, // 月曜日
        periodNumber: 1,
      );

      expect(classItem.id, '1');
      expect(classItem.subjectId, 'sub1');
      expect(classItem.teacherId, 'tea1');
      expect(classItem.roomId, 'room1');
      expect(classItem.startTime, 540);
      expect(classItem.endTime, 630);
      expect(classItem.memo, null);
      expect(classItem.dayOfWeek, 1);
      expect(classItem.periodNumber, 1);
    });

    test('should create a class with optional memo', () {
      final classItem = Class(
        id: '1',
        subjectId: 'sub1',
        teacherId: 'tea1',
        roomId: 'room1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
        memo: 'テストメモ',
        periodNumber: 1,
      );

      expect(classItem.memo, 'テストメモ');
    });

    test('should convert to and from JSON', () {
      final classItem = Class(
        id: '1',
        subjectId: 'sub1',
        teacherId: 't1',
        roomId: 'r1',
        startTime: 540,
        endTime: 630,
        dayOfWeek: 1,
        periodNumber: 1,
      );

      final json = classItem.toJson();
      final fromJson = Class.fromJson(json);

      expect(fromJson.id, classItem.id);
      expect(fromJson.subjectId, classItem.subjectId);
      expect(fromJson.teacherId, classItem.teacherId);
      expect(fromJson.roomId, classItem.roomId);
      expect(fromJson.startTime, classItem.startTime);
      expect(fromJson.endTime, classItem.endTime);
      expect(fromJson.dayOfWeek, classItem.dayOfWeek);
      expect(fromJson.periodNumber, classItem.periodNumber);
    });

    test('should handle missing dayOfWeek in JSON', () {
      final json = {
        'id': '1',
        'subjectId': 'sub1',
        'teacherId': 'tea1',
        'roomId': 'room1',
        'startTime': 540,
        'endTime': 630,
        'memo': 'テストメモ',
        'periodNumber': 1,
      };

      final fromJson = Class.fromJson(json);
      expect(fromJson.dayOfWeek, 0);
    });
  });
} 