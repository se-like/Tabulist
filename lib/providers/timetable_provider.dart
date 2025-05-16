import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class.dart';

class TimetableProvider with ChangeNotifier {
  List<Class> _classes = [];
  final String _storageKey = 'timetable_data';

  List<Class> get classes => _classes;

  TimetableProvider() {
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? classesJson = prefs.getString(_storageKey);
    if (classesJson != null) {
      final List<dynamic> decodedClasses = json.decode(classesJson);
      _classes = decodedClasses.map((item) => Class.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedClasses =
        json.encode(_classes.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, encodedClasses);
  }

  void addClass(Class newClass) {
    _classes.add(newClass);
    _saveClasses();
    notifyListeners();
  }

  void updateClass(Class updatedClass) {
    final index = _classes.indexWhere((c) => c.id == updatedClass.id);
    if (index != -1) {
      _classes[index] = updatedClass;
      _saveClasses();
      notifyListeners();
    }
  }

  void deleteClass(String id) {
    _classes.removeWhere((c) => c.id == id);
    _saveClasses();
    notifyListeners();
  }

  List<Class> getClassesForDay(int dayOfWeek) {
    return _classes.where((c) => c.dayOfWeek == dayOfWeek).toList();
  }
}
