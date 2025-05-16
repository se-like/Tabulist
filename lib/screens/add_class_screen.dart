import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class.dart';
import '../providers/timetable_provider.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _memoController = TextEditingController();
  int _selectedDay = 0;
  int _startTime = 9;
  int _endTime = 10;

  final List<String> _days = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _saveClass() {
    if (_formKey.currentState!.validate()) {
      final newClass = Class(
        id: DateTime.now().toString(),
        name: _nameController.text,
        teacher: _teacherController.text,
        room: _roomController.text,
        dayOfWeek: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        memo: _memoController.text,
      );

      context.read<TimetableProvider>().addClass(newClass);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('授業を追加'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '授業名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '授業名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: '担当教員',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '担当教員を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: '教室',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '教室を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: '曜日',
                border: OutlineInputBorder(),
              ),
              items: List.generate(7, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(_days[index]),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _startTime,
                    decoration: const InputDecoration(
                      labelText: '開始時間',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(24, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index:00'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _startTime = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _endTime,
                    decoration: const InputDecoration(
                      labelText: '終了時間',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(24, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index:00'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _endTime = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
}
