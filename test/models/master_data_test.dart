import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/models/master_data.dart';

void main() {
  group('Subject Model Tests', () {
    test('should create a subject with required fields', () {
      final subject = Subject(
        id: '1',
        name: '数学',
      );

      expect(subject.id, '1');
      expect(subject.name, '数学');
      expect(subject.description, null);
      expect(subject.color, null);
    });

    test('should create a subject with optional fields', () {
      final subject = Subject(
        id: '1',
        name: '数学',
        description: '高等数学',
        color: 0xFF000000,
      );

      expect(subject.description, '高等数学');
      expect(subject.color, 0xFF000000);
    });

    test('should convert to and from JSON', () {
      final subject = Subject(
        id: '1',
        name: '数学',
        description: '高等数学',
        color: 0xFF000000,
      );

      final json = subject.toJson();
      final fromJson = Subject.fromJson(json);

      expect(fromJson.id, subject.id);
      expect(fromJson.name, subject.name);
      expect(fromJson.description, subject.description);
      expect(fromJson.color, subject.color);
    });
  });

  group('Teacher Model Tests', () {
    test('should create a teacher with required fields', () {
      final teacher = Teacher(
        id: '1',
        name: '山田先生',
      );

      expect(teacher.id, '1');
      expect(teacher.name, '山田先生');
      expect(teacher.email, null);
      expect(teacher.phone, null);
    });

    test('should create a teacher with optional fields', () {
      final teacher = Teacher(
        id: '1',
        name: '山田先生',
        email: 'yamada@example.com',
        phone: '090-1234-5678',
      );

      expect(teacher.email, 'yamada@example.com');
      expect(teacher.phone, '090-1234-5678');
    });

    test('should convert to and from JSON', () {
      final teacher = Teacher(
        id: '1',
        name: '山田先生',
        email: 'yamada@example.com',
        phone: '090-1234-5678',
      );

      final json = teacher.toJson();
      final fromJson = Teacher.fromJson(json);

      expect(fromJson.id, teacher.id);
      expect(fromJson.name, teacher.name);
      expect(fromJson.email, teacher.email);
      expect(fromJson.phone, teacher.phone);
    });
  });

  group('Room Model Tests', () {
    test('should create a room with required fields', () {
      final room = Room(
        id: '1',
        name: '101教室',
      );

      expect(room.id, '1');
      expect(room.name, '101教室');
      expect(room.building, null);
      expect(room.floor, null);
      expect(room.capacity, null);
    });

    test('should create a room with optional fields', () {
      final room = Room(
        id: '1',
        name: '101教室',
        building: '本館',
        floor: 1,
        capacity: 40,
      );

      expect(room.building, '本館');
      expect(room.floor, 1);
      expect(room.capacity, 40);
    });

    test('should convert to and from JSON', () {
      final room = Room(
        id: '1',
        name: '101教室',
        building: '本館',
        floor: 1,
        capacity: 40,
      );

      final json = room.toJson();
      final fromJson = Room.fromJson(json);

      expect(fromJson.id, room.id);
      expect(fromJson.name, room.name);
      expect(fromJson.building, room.building);
      expect(fromJson.floor, room.floor);
      expect(fromJson.capacity, room.capacity);
    });
  });
} 