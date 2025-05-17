import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ads_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('テーマ'),
            subtitle: const Text('アプリの見た目を変更'),
            trailing: DropdownButton<ThemeMode>(
              key: const Key('themeDropdown'),
              value: AppTheme.currentThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('システム設定に従う'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('ライト'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('ダーク'),
                ),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  AppTheme.setThemeMode(newMode);
                }
              },
            ),
          ),
          SwitchListTile(
            key: const Key('adsSwitch'),
            title: const Text('広告を表示'),
            subtitle: const Text('アプリ内の広告の表示/非表示を切り替え'),
            value: AdsService.isAdsEnabled,
            onChanged: (bool value) {
              AdsService.setAdsEnabled(value);
            },
          ),
        ],
      ),
    );
  }
} 