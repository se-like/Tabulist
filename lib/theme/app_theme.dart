import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeModeKey = 'theme_mode';
  static ThemeMode _currentThemeMode = ThemeMode.system;

  static ThemeMode get currentThemeMode => _currentThemeMode;

  static ThemeData get currentTheme {
    return _currentThemeMode == ThemeMode.dark ? _darkTheme : _lightTheme;
  }

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _currentThemeMode = ThemeMode.values[themeModeIndex];
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    _currentThemeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// テスト用: テーマ状態をリセット
  static void resetForTest() {
    _currentThemeMode = ThemeMode.system;
  }
} 