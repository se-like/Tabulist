import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class.dart';

class TimetableProvider extends ChangeNotifier {
  static const String _classesKey = 'classes';
  final SharedPreferences prefs;
  final List<Class> _classes = [];
  bool _isInitialized = false;
  int _currentDayOfWeek = DateTime.now().weekday;

  TimetableProvider({required this.prefs});

  List<Class> get classes => _classes;
  bool get isInitialized => _isInitialized;
  int get currentDayOfWeek => _currentDayOfWeek;

  Future<void> initialize() async {
    try {
      _isInitialized = false;
      await _loadClasses();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing TimetableProvider: $e');
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadClasses() async {
    try {
      final jsonString = prefs.getString(_classesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _classes.clear();
        _classes.addAll(
          jsonList.map((json) => Class.fromJson(json as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      print('Error loading classes: $e');
      _classes.clear();
      rethrow;
    }
  }

  Future<void> _saveClasses() async {
    if (!_isInitialized) {
      await initialize();
    }
    final jsonString = json.encode(_classes.map((c) => c.toJson()).toList());
    await prefs.setString(_classesKey, jsonString);
    notifyListeners();
  }

  Future<void> addClass(Class classItem) async {
    if (!_isInitialized) {
      await initialize();
    }
    _classes.add(classItem);
    await _saveClasses();
    notifyListeners();
  }

  Future<void> updateClass(Class classItem) async {
    if (!_isInitialized) {
      await initialize();
    }
    final index = _classes.indexWhere((c) => c.id == classItem.id);
    if (index != -1) {
      _classes[index] = classItem;
      await _saveClasses();
      notifyListeners();
    }
  }

  Future<void> deleteClass(String id) async {
    if (!_isInitialized) {
      await initialize();
    }
    _classes.removeWhere((c) => c.id == id);
    await _saveClasses();
    notifyListeners();
  }

  List<Class> getClassesForDay(int dayOfWeek) {
    if (!_isInitialized) {
      return [];
    }
    return _classes.where((c) => c.dayOfWeek == dayOfWeek && c.isActive).toList();
  }

  List<Class> getClassesByDay(int dayOfWeek) {
    if (!_isInitialized) {
      return [];
    }
    return _classes.where((c) => c.dayOfWeek == dayOfWeek).toList();
  }

  void setCurrentDayOfWeek(int day) {
    if (day >= 1 && day <= 7) {
      _currentDayOfWeek = day;
      notifyListeners();
    }
  }

  Class? getClassByPeriod(int dayOfWeek, int periodNumber) {
    if (!_isInitialized) {
      return null;
    }
    try {
      return _classes.firstWhere(
        (c) => c.dayOfWeek == dayOfWeek && c.periodNumber == periodNumber,
      );
    } catch (e) {
      return null;
    }
  }
}
