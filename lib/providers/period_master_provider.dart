import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_master.dart';

class PeriodMasterProvider with ChangeNotifier {
  List<PeriodMaster> _periodMasters = [];
  List<PeriodMaster> get periodMasters => _periodMasters;
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  String? _lastError;
  String? get lastError => _lastError;

  PeriodMasterProvider({SharedPreferences? prefs}) {
    _prefs = prefs;
  }

  Future<void> initialize() async {
    try {
      _isInitialized = false;
      _lastError = null;
      await loadPeriodMasters();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = '初期化中にエラーが発生しました: $e';
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPeriodMasters() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final periodMastersJson = prefs.getStringList('periodMasters') ?? [];
      _periodMasters = periodMastersJson
          .map((json) => PeriodMaster.fromJson(jsonDecode(json)))
          .toList();
      _lastError = null;
    } catch (e) {
      _lastError = '時限マスターの読み込み中にエラーが発生しました: $e';
      _periodMasters = [];
      rethrow;
    }
  }

  Future<void> savePeriodMasters() async {
    if (!_isInitialized) {
      _lastError = '時限マスターが初期化されていません';
      notifyListeners();
      return;
    }
    
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final periodMastersJson = _periodMasters
          .map((master) => jsonEncode(master.toJson()))
          .toList();
      await prefs.setStringList('periodMasters', periodMastersJson);
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = '時限マスターの保存中にエラーが発生しました: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addPeriodMaster(PeriodMaster periodMaster) async {
    if (!_isInitialized) {
      await initialize();
    }
    _periodMasters.add(periodMaster);
    await savePeriodMasters();
    notifyListeners();
  }

  Future<void> updatePeriodMaster(PeriodMaster periodMaster) async {
    if (!_isInitialized) {
      await initialize();
    }
    final index = _periodMasters.indexWhere((m) => m.id == periodMaster.id);
    if (index != -1) {
      _periodMasters[index] = periodMaster;
      await savePeriodMasters();
      notifyListeners();
    }
  }

  Future<void> deletePeriodMaster(String id) async {
    if (!_isInitialized) {
      await initialize();
    }
    _periodMasters.removeWhere((m) => m.id == id);
    await savePeriodMasters();
    notifyListeners();
  }

  PeriodMaster? getPeriodMasterByDay(int day) {
    print('PeriodMasterProvider: getPeriodMasterByDay開始');
    print('PeriodMasterProvider: 引数day = $day');
    print('PeriodMasterProvider: _isInitialized = $_isInitialized');
    
    if (!_isInitialized) {
      print('PeriodMasterProvider: 初期化されていません');
      _lastError = '時限マスターの初期化が完了していません';
      notifyListeners();
      return null;
    }
    
    print('PeriodMasterProvider: _periodMasters = $_periodMasters');
    print('PeriodMasterProvider: _periodMastersの長さ = ${_periodMasters.length}');
    
    try {
      final result = _periodMasters.firstWhere((master) {
        print('PeriodMasterProvider: 比較: master.dayOfWeek(${master.dayOfWeek}) == day($day)');
        return master.dayOfWeek == day;
      });
      print('PeriodMasterProvider: 一致するPeriodMasterを発見: $result');
      return result;
    } catch (e) {
      print('PeriodMasterProvider: 一致するPeriodMasterが見つかりません: $e');
      return null;
    }
  }

  bool isPeriodAvailable(int day, int period) {
    if (!_isInitialized) {
      _lastError = '時限マスターの初期化が完了していません';
      notifyListeners();
      return false;
    }
    final master = _periodMasters[day];
    if (master == null) return false;
    return period <= master.periods.length;
  }

  Future<void> generateTemplateForAllWeekdays(
    TimeOfDay startTime,
    int classDuration,
    int breakDuration,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _lastError = null;
      // 既存の時限マスターを全て削除
      _periodMasters.clear();

      // 月曜日から金曜日までのテンプレートを生成
      for (int dayOfWeek = 1; dayOfWeek <= 5; dayOfWeek++) {
        print('テンプレート生成: dayOfWeek=$dayOfWeek');
        final periods = List.generate(
          6,
          (index) => Period(
            id: '${dayOfWeek}_${index + 1}',
            periodNumber: index + 1,
            duration: classDuration,
            isEnabled: true,
            breakDuration: breakDuration,
          ),
        );

        final periodMaster = PeriodMaster(
          id: 'master_$dayOfWeek',
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          periods: periods,
        );

        _periodMasters.add(periodMaster);
      }

      await savePeriodMasters();
      print('テンプレート生成後: $_periodMasters');
      notifyListeners();
    } catch (e) {
      _lastError = 'テンプレート生成中にエラーが発生しました: $e';
      notifyListeners();
      rethrow;
    }
  }
} 