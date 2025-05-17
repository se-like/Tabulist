import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class.dart';
import '../providers/timetable_provider.dart';
import '../providers/master_data_provider.dart';
import '../providers/period_master_provider.dart';
import '../models/period_master.dart';

class AddClassScreen extends StatefulWidget {
  final int periodNumber;
  final int dayOfWeek;

  const AddClassScreen({
    super.key,
    required this.periodNumber,
    required this.dayOfWeek,
  });

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _subjectId;
  late String _teacherId;
  late String _roomId;
  late String _memo;
  late int _dayOfWeek;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    print('授業登録画面: initState開始');
    print('授業登録画面: periodNumber = ${widget.periodNumber}, dayOfWeek = ${widget.dayOfWeek}');
    // 自クラスを初期値として設定
    final masterDataProvider = context.read<MasterDataProvider>();
    final selfClass = masterDataProvider.rooms.firstWhere(
      (room) => room.name == '自クラス',
      orElse: () => masterDataProvider.rooms.first,
    );
    _roomId = selfClass.id;
    _subjectId = '';
    _teacherId = '';
    _memo = '';
    _dayOfWeek = widget.dayOfWeek;
    _isActive = true;
  }

  @override
  Widget build(BuildContext context) {
    print('授業登録画面: build開始');
    print('授業登録画面: dayOfWeek = ${widget.dayOfWeek}');
    final masterDataProvider = context.watch<MasterDataProvider>();
    final timetableProvider = context.watch<TimetableProvider>();
    final periodMasterProvider = context.watch<PeriodMasterProvider>();

    print('授業登録画面: periodMasterProvider.isInitialized = ${periodMasterProvider.isInitialized}');
    print('授業登録画面: periodMasters = ${periodMasterProvider.periodMasters}');
    print('授業登録画面: periodMasters dayOfWeek = ${periodMasterProvider.periodMasters.map((m) => m.dayOfWeek).toList()}');

    if (!masterDataProvider.isInitialized || !periodMasterProvider.isInitialized) {
      print('授業登録画面: プロバイダーが初期化されていません');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final periodMaster = periodMasterProvider.getPeriodMasterByDay(widget.dayOfWeek);
    print('授業登録画面: periodMaster = $periodMaster');
    print('授業登録画面: periodMaster?.periods = ${periodMaster?.periods}');

    if (periodMaster == null) {
      print('授業登録画面: periodMasterがnullです');
      return Scaffold(
        appBar: AppBar(
          title: const Text('授業登録'),
        ),
        body: const Center(
          child: Text('時限マスターが設定されていません'),
        ),
      );
    }

    final period = periodMaster.periods.firstWhere(
      (p) => p.periodNumber == widget.periodNumber,
      orElse: () => Period(
        id: '',
        periodNumber: widget.periodNumber,
        duration: 0,
        isEnabled: false,
        breakDuration: 0,
      ),
    );
    print('授業登録画面: period = $period');
    print('授業登録画面: period.isEnabled = ${period.isEnabled}');

    if (period == null || !period.isEnabled) {
      print('授業登録画面: periodがnullまたは無効なため保存を中止');
      return Scaffold(
        appBar: AppBar(
          title: const Text('授業登録'),
        ),
        body: const Center(
          child: Text('選択された時限は利用できません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('授業を追加'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '科目',
                border: OutlineInputBorder(),
              ),
              value: _subjectId.isEmpty ? null : _subjectId,
              items: masterDataProvider.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _subjectId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '科目を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '教員',
                border: OutlineInputBorder(),
              ),
              value: _teacherId.isEmpty ? null : _teacherId,
              items: masterDataProvider.teachers.map((teacher) {
                return DropdownMenuItem(
                  value: teacher.id,
                  child: Text(teacher.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _teacherId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '教員を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '教室',
                border: OutlineInputBorder(),
              ),
              value: _roomId.isEmpty ? null : _roomId,
              items: masterDataProvider.rooms.map((room) {
                return DropdownMenuItem(
                  value: room.id,
                  child: Text(room.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _roomId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '教室を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) {
                if (value != null) {
                  _memo = value;
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('この授業を使用する'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveClass,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveClass() async {
    print('授業登録画面: _saveClass開始');
    print('授業登録画面: フォームの値 - subjectId: $_subjectId, teacherId: $_teacherId, roomId: $_roomId, memo: $_memo');
    print('授業登録画面: dayOfWeek = ${widget.dayOfWeek}');
    if (_formKey.currentState!.validate()) {
      print('授業登録画面: フォームのバリデーション成功');
      _formKey.currentState!.save();
      final timetableProvider = context.read<TimetableProvider>();
      final periodMasterProvider = context.read<PeriodMasterProvider>();
      final periodMaster = periodMasterProvider.getPeriodMasterByDay(widget.dayOfWeek);
      print('授業登録画面: periodMaster = $periodMaster');
      if (periodMaster == null) {
        print('授業登録画面: periodMasterがnullのため保存を中止');
        return;
      }
      final period = periodMaster.periods.firstWhere(
        (p) => p.periodNumber == widget.periodNumber,
        orElse: () => null as Period,
      );
      print('授業登録画面: period = $period');
      if (period == null || !period.isEnabled) {
        print('授業登録画面: periodがnullまたは無効なため保存を中止');
        return;
      }
      print('授業登録画面: 授業データの保存を開始');
      await timetableProvider.addClass(
        Class(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          subjectId: _subjectId,
          teacherId: _teacherId,
          roomId: _roomId,
          startTime: periodMaster.startTime.hour,
          endTime: periodMaster.startTime.hour + (period.duration ~/ 60),
          dayOfWeek: _dayOfWeek,
          memo: _memo,
          periodNumber: widget.periodNumber,
          isActive: _isActive,
        ),
      );
      print('授業登録画面: 授業データの保存が完了');
      if (mounted) {
        print('授業登録画面: 画面を閉じる');
        Navigator.pop(context);
      }
    } else {
      print('授業登録画面: フォームのバリデーション失敗');
    }
  }
}
