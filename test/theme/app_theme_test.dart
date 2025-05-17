import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabulist/theme/app_theme.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await AppTheme.initialize();
  });

  group('AppTheme Tests', () {
    test('初期化時にシステム設定がデフォルト', () async {
      expect(AppTheme.currentThemeMode, equals(ThemeMode.system));
    });

    test('テーマモードの変更が正しく保存される', () async {
      await AppTheme.setThemeMode(ThemeMode.dark);
      expect(AppTheme.currentThemeMode, equals(ThemeMode.dark));
      
      // SharedPreferencesに保存されていることを確認
      final savedIndex = prefs.getInt('theme_mode');
      expect(savedIndex, equals(ThemeMode.dark.index));
    });

    test('保存されたテーマモードが正しく読み込まれる', () async {
      // ダークモードを保存
      await prefs.setInt('theme_mode', ThemeMode.dark.index);
      
      // 初期化して読み込み
      await AppTheme.initialize();
      expect(AppTheme.currentThemeMode, equals(ThemeMode.dark));
    });

    test('currentThemeが正しいテーマを返す', () {
      // ライトモード
      AppTheme.setThemeMode(ThemeMode.light);
      expect(AppTheme.currentTheme.brightness, equals(Brightness.light));

      // ダークモード
      AppTheme.setThemeMode(ThemeMode.dark);
      expect(AppTheme.currentTheme.brightness, equals(Brightness.dark));
    });

    test('デフォルトテーマが設定されている', () {
      expect(AppTheme.currentTheme, isA<ThemeData>());
      // システム設定に従うため、brightnessの確認は行わない
    });

    test('テーマを切り替えられる', () {
      // ダークテーマに切り替え
      AppTheme.setThemeMode(ThemeMode.dark);
      expect(AppTheme.currentTheme.brightness, equals(Brightness.dark));

      // ライトテーマに切り替え
      AppTheme.setThemeMode(ThemeMode.light);
      expect(AppTheme.currentTheme.brightness, equals(Brightness.light));

      // システムテーマに切り替え
      AppTheme.setThemeMode(ThemeMode.system);
      expect(AppTheme.currentTheme, isA<ThemeData>());
    });

    test('カラースキームが正しく設定されている', () {
      final colorScheme = AppTheme.currentTheme.colorScheme;
      expect(colorScheme.primary, isA<Color>());
      expect(colorScheme.secondary, isA<Color>());
      expect(colorScheme.surface, isA<Color>());
      expect(colorScheme.background, isA<Color>());
    });
  });
} 