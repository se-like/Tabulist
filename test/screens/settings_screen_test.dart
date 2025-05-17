import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabulist/screens/settings_screen.dart';
import 'package:tabulist/services/ads_service.dart';
import 'package:tabulist/theme/app_theme.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await AppTheme.initialize();
    // AdsServiceの初期化や状態操作は行わない
    AppTheme.resetForTest();
    AdsService.resetForTest();
  });

  testWidgets('設定画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('テーマ'), findsOneWidget);
    expect(find.text('広告を表示'), findsOneWidget);
  });

  testWidgets('テーマの変更が正しく動作する', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(),
      ),
    );

    final themeDropdown = find.byKey(const Key('themeDropdown'));
    expect(themeDropdown, findsOneWidget);
    await tester.tap(themeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ダーク').last);
    await tester.pumpAndSettle();
    expect(AppTheme.currentThemeMode, ThemeMode.dark);
  });

  testWidgets('広告設定の切り替えが正しく動作する', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(),
      ),
    );

    final adsSwitch = find.byKey(const Key('adsSwitch'));
    expect(adsSwitch, findsOneWidget);
    await tester.tap(adsSwitch);
    await tester.pumpAndSettle();
    expect(AdsService.isAdsEnabled, false);
  });
} 