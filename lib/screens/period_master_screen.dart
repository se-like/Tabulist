import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/providers/period_master_provider.dart';
import 'package:tabulist/screens/home_screen.dart';

class PeriodMasterScreen extends StatefulWidget {
  const PeriodMasterScreen({Key? key}) : super(key: key);

  @override
  _PeriodMasterScreenState createState() => _PeriodMasterScreenState();
}

class _PeriodMasterScreenState extends State<PeriodMasterScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  final List<int> _classDurations = [45];
  final List<int> _breakDurations = [10];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _generateTemplate() async {
    final provider = Provider.of<PeriodMasterProvider>(context, listen: false);
    final hasExistingMasters = provider.periodMasters.isNotEmpty;
    
    if (hasExistingMasters) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('確認'),
          content: const Text('既存の時限マスターを上書きしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('上書き'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    // 授業時間と休憩時間のリストから最初の値を取得
    final classDuration = _classDurations.first;
    final breakDuration = _breakDurations.first;

    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await provider.generateTemplateForAllWeekdays(
        _startTime,
        classDuration,
        breakDuration,
      );
      
      if (!mounted) return;

      // ローディングを閉じる
      Navigator.pop(context);

      // データが確実に保存されるのを待つ
      await Future.delayed(const Duration(milliseconds: 500));

      // エラーが発生していないか確認
      if (provider.lastError != null) {
        throw Exception(provider.lastError);
      }

      // ナビゲーションスタックをクリアしてホーム画面に戻る
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      // ローディングを閉じる
      Navigator.pop(context);
      
      // エラーが発生した場合はユーザーに通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('時限マスターの生成中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '再試行',
            onPressed: () {
              _generateTemplate();
            },
          ),
        ),
      );
    }
  }

  Widget _buildDurationList(
    String title,
    List<int> durations,
    Function(int) onAdd,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...durations.asMap().entries.map((entry) {
          final index = entry.key;
          final duration = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '分数',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: duration.toString()),
                  onChanged: (value) {
                    final newValue = int.tryParse(value);
                    if (newValue != null) {
                      setState(() {
                        durations[index] = newValue;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (durations.length > 1) {
                    setState(() {
                      onRemove(index);
                    });
                  }
                },
              ),
            ],
          );
        }),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onAdd(45),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時限マスター'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('開始時刻'),
            subtitle: Text(
              '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context),
          ),
          const SizedBox(height: 16),
          _buildDurationList(
            '授業時間',
            _classDurations,
            (value) {
              setState(() {
                _classDurations.add(value);
              });
            },
            (index) {
              setState(() {
                _classDurations.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDurationList(
            '休憩時間',
            _breakDurations,
            (value) {
              setState(() {
                _breakDurations.add(value);
              });
            },
            (index) {
              setState(() {
                _breakDurations.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _generateTemplate,
              child: const Text('テンプレート生成'),
            ),
          ),
        ],
      ),
    );
  }
} 