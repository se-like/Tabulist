import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/master_data.dart';
import 'package:uuid/uuid.dart';

class MasterDataProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  List<Teacher> _teachers = [];
  List<Room> _rooms = [];

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  List<Subject> get subjects => _subjects;
  List<Teacher> get teachers => _teachers;
  List<Room> get rooms => _rooms;
  bool get isInitialized => _isInitialized;

  MasterDataProvider({SharedPreferences? prefs}) {
    _prefs = prefs;
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // 既存のマスターデータを読み込む
      final jsonString = _prefs?.getString('master_data');
      if (jsonString != null) {
        final Map<String, dynamic> data = json.decode(jsonString);
        _subjects = (data['subjects'] as List)
            .map((item) => Subject.fromJson(item))
            .toList();
        _teachers = (data['teachers'] as List)
            .map((item) => Teacher.fromJson(item))
            .toList();
        _rooms = (data['rooms'] as List)
            .map((item) => Room.fromJson(item))
            .toList();
      }

      // 自クラスが存在しない場合は追加
      if (!_rooms.any((room) => room.name == '自クラス')) {
        final ownClass = Room(
          id: const Uuid().v4(),
          name: '自クラス',
        );
        _rooms.add(ownClass);
        await _saveMasterData();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('マスターデータの初期化中にエラーが発生しました: $e');
      rethrow;
    }
  }

  Future<void> loadMasterData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    
    // 科目データの読み込み
    final subjectsJson = prefs.getString('subjects');
    if (subjectsJson != null) {
      final List<dynamic> decoded = json.decode(subjectsJson);
      _subjects = decoded.map((item) => Subject.fromJson(item)).toList();
    }

    // 教員データの読み込み
    final teachersJson = prefs.getString('teachers');
    if (teachersJson != null) {
      final List<dynamic> decoded = json.decode(teachersJson);
      _teachers = decoded.map((item) => Teacher.fromJson(item)).toList();
    }

    // 教室データの読み込み
    final roomsJson = prefs.getString('rooms');
    if (roomsJson != null) {
      final List<dynamic> decoded = json.decode(roomsJson);
      _rooms = decoded.map((item) => Room.fromJson(item)).toList();
    }

    notifyListeners();
  }

  Future<void> addSubject(Subject subject) async {
    _subjects.add(subject);
    await _saveSubjects();
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    _teachers.add(teacher);
    await _saveTeachers();
    notifyListeners();
  }

  Future<void> addRoom(Room room) async {
    _rooms.add(room);
    await _saveRooms();
    notifyListeners();
  }

  Future<void> updateSubject(Subject subject) async {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
      await _saveSubjects();
      notifyListeners();
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index != -1) {
      _teachers[index] = teacher;
      await _saveTeachers();
      notifyListeners();
    }
  }

  Future<void> updateRoom(Room room) async {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
      await _saveRooms();
      notifyListeners();
    }
  }

  Future<void> deleteSubject(String id) async {
    _subjects.removeWhere((s) => s.id == id);
    await _saveSubjects();
    notifyListeners();
  }

  Future<void> deleteTeacher(String id) async {
    _teachers.removeWhere((t) => t.id == id);
    await _saveTeachers();
    notifyListeners();
  }

  Future<void> deleteRoom(String id) async {
    _rooms.removeWhere((r) => r.id == id);
    await _saveRooms();
    notifyListeners();
  }

  Future<void> _saveSubjects() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_subjects.map((s) => s.toJson()).toList());
    await prefs.setString('subjects', jsonStr);
  }

  Future<void> _saveTeachers() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_teachers.map((t) => t.toJson()).toList());
    await prefs.setString('teachers', jsonStr);
  }

  Future<void> _saveRooms() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_rooms.map((r) => r.toJson()).toList());
    await prefs.setString('rooms', jsonStr);
  }

  Future<void> _saveMasterData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode({
      'subjects': _subjects.map((s) => s.toJson()).toList(),
      'teachers': _teachers.map((t) => t.toJson()).toList(),
      'rooms': _rooms.map((r) => r.toJson()).toList(),
    });
    await prefs.setString('master_data', jsonStr);
  }
} 