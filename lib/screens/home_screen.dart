import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timetable_provider.dart';
import '../models/class.dart';
import 'add_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDay = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabulist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddClassScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: _buildTimetable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['月', '火', '水', '木', '金', '土', '日'];
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = index;
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _selectedDay == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: _selectedDay == index
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetable() {
    return Consumer<TimetableProvider>(
      builder: (context, timetableProvider, child) {
        final classes = timetableProvider.getClassesForDay(_selectedDay);
        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classItem = classes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(classItem.name),
                subtitle: Text('${classItem.teacher} - ${classItem.room}'),
                trailing: Text(
                  '${classItem.startTime}:00 - ${classItem.endTime}:00',
                ),
                onTap: () {
                  // TODO: 授業詳細画面への遷移
                },
              ),
            );
          },
        );
      },
    );
  }
}
