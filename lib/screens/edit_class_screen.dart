import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class.dart';
import '../providers/master_data_provider.dart';
import '../providers/timetable_provider.dart';
import '../screens/add_class_screen.dart';

class EditClassScreen extends StatefulWidget {
  final Class classItem;

  const EditClassScreen({
    super.key,
    required this.classItem,
  });

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _subjectId;
  late String _teacherId;
  late String _roomId;
  late int _startTime;
  late int _endTime;
  late String _memo;
  late int _dayOfWeek;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.classItem.subjectId;
    _teacherId = widget.classItem.teacherId;
    _roomId = widget.classItem.roomId;
    _startTime = widget.classItem.startTime;
    _endTime = widget.classItem.endTime;
    _memo = widget.classItem.memo ?? '';
    _dayOfWeek = widget.classItem.dayOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    final masterDataProvider = context.watch<MasterDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('授業を編集'),
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
              value: _subjectId,
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
              value: _teacherId,
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
              value: _roomId,
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
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: '曜日',
                border: OutlineInputBorder(),
              ),
              value: _dayOfWeek,
              items: const [
                DropdownMenuItem(value: 1, child: Text('月曜日')),
                DropdownMenuItem(value: 2, child: Text('火曜日')),
                DropdownMenuItem(value: 3, child: Text('水曜日')),
                DropdownMenuItem(value: 4, child: Text('木曜日')),
                DropdownMenuItem(value: 5, child: Text('金曜日')),
                DropdownMenuItem(value: 6, child: Text('土曜日')),
                DropdownMenuItem(value: 7, child: Text('日曜日')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _dayOfWeek = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return '曜日を選択してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: '開始時間',
                      border: OutlineInputBorder(),
                    ),
                    value: _startTime,
                    items: List.generate(24, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index時'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _startTime = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return '開始時間を選択してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: '終了時間',
                      border: OutlineInputBorder(),
                    ),
                    value: _endTime,
                    items: List.generate(24, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('$index時'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _endTime = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return '終了時間を選択してください';
                      }
                      if (value <= _startTime) {
                        return '終了時間は開始時間より後を選択してください';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              initialValue: _memo,
              onSaved: (value) {
                if (value != null) {
                  _memo = value;
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateClass,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateClass() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final timetableProvider = context.read<TimetableProvider>();
      await timetableProvider.updateClass(
        Class(
          id: widget.classItem.id,
          subjectId: _subjectId,
          teacherId: _teacherId,
          roomId: _roomId,
          startTime: _startTime,
          endTime: _endTime,
          dayOfWeek: _dayOfWeek,
          memo: _memo,
          periodNumber: widget.classItem.periodNumber,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToAddClass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClassScreen(
          periodNumber: widget.classItem.periodNumber,
          dayOfWeek: widget.classItem.dayOfWeek,
        ),
      ),
    );
  }
} 