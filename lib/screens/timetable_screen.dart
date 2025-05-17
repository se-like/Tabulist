import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class.dart';
import '../models/master_data.dart';
import '../providers/master_data_provider.dart';
import '../providers/timetable_provider.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timetableProvider = context.watch<TimetableProvider>();
    final masterDataProvider = context.watch<MasterDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-class');
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 7,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: const [
                Tab(text: '月曜日'),
                Tab(text: '火曜日'),
                Tab(text: '水曜日'),
                Tab(text: '木曜日'),
                Tab(text: '金曜日'),
                Tab(text: '土曜日'),
                Tab(text: '日曜日'),
              ],
              onTap: (index) {
                timetableProvider.setCurrentDayOfWeek(index + 1);
              },
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(7, (index) {
                  final dayOfWeek = index + 1;
                  final classes = timetableProvider.getClassesForDay(dayOfWeek);
                  return _buildDayTimetable(
                    context,
                    classes,
                    masterDataProvider,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTimetable(
    BuildContext context,
    List<Class> classes,
    MasterDataProvider masterDataProvider,
  ) {
    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, hour) {
        final classesAtHour = classes.where((c) => c.startTime == hour).toList();
        if (classesAtHour.isEmpty) {
          return _buildEmptyTimeSlot(hour);
        }
        return _buildClassSlot(context, classesAtHour, masterDataProvider);
      },
    );
  }

  Widget _buildEmptyTimeSlot(int hour) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('空き時間'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSlot(
    BuildContext context,
    List<Class> classes,
    MasterDataProvider masterDataProvider,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${classes.first.startTime.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classItem = classes[index];
                final subject = masterDataProvider.subjects
                    .firstWhere((s) => s.id == classItem.subjectId);
                final teacher = masterDataProvider.teachers
                    .firstWhere((t) => t.id == classItem.teacherId);
                final room = masterDataProvider.rooms
                    .firstWhere((r) => r.id == classItem.roomId);

                return GestureDetector(
                  onTap: () => _showClassDetails(context, classItem, subject, teacher, room),
                  onLongPress: () => _showEditMenu(context, classItem),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${teacher.name} / ${room.name}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClassDetails(
    BuildContext context,
    Class classItem,
    Subject subject,
    Teacher teacher,
    Room room,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('授業詳細'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('科目: ${subject.name}'),
            Text('教員: ${teacher.name}'),
            Text('教室: ${room.name}'),
            Text('時間: ${classItem.startTime}:00 - ${classItem.endTime}:00'),
            if (classItem.memo != null && classItem.memo!.isNotEmpty)
              Text('メモ: ${classItem.memo}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showEditMenu(BuildContext context, Class classItem) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('編集'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/edit-class',
                arguments: classItem,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('削除'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, classItem);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Class classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('授業の削除'),
        content: const Text('この授業を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<TimetableProvider>().deleteClass(classItem.id);
              Navigator.pop(context);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
} 