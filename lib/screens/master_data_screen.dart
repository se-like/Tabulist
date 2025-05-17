import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/master_data_provider.dart';
import '../models/master_data.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text('マスターデータ管理'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: '科目'),
                  Tab(text: '教員'),
                  Tab(text: '教室'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildSubjectList(context),
                _buildTeacherList(context),
                _buildRoomList(context),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final currentIndex = tabController.index;
                switch (currentIndex) {
                  case 0:
                    _showAddSubjectDialog(context);
                    break;
                  case 1:
                    _showAddTeacherDialog(context);
                    break;
                  case 2:
                    _showAddRoomDialog(context);
                    break;
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.subjects.length,
          itemBuilder: (context, index) {
            final subject = provider.subjects[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(subject.name),
                subtitle: subject.description != null
                    ? Text(subject.description!)
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.deleteSubject(subject.id),
                ),
                onTap: () => _showEditSubjectDialog(context, subject),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeacherList(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.teachers.length,
          itemBuilder: (context, index) {
            final teacher = provider.teachers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(teacher.name),
                subtitle: teacher.email != null ? Text(teacher.email!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.deleteTeacher(teacher.id),
                ),
                onTap: () => _showEditTeacherDialog(context, teacher),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoomList(BuildContext context) {
    return Consumer<MasterDataProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.rooms.length,
          itemBuilder: (context, index) {
            final room = provider.rooms[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(room.name),
                subtitle: room.building != null
                    ? Text('${room.building} ${room.floor != null ? "${room.floor}階" : ""}')
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.deleteRoom(room.id),
                ),
                onTap: () => _showEditRoomDialog(context, room),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('科目を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '科目名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final subject = Subject(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );
                context.read<MasterDataProvider>().addSubject(subject);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    final descriptionController = TextEditingController(text: subject.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('科目を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '科目名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedSubject = Subject(
                  id: subject.id,
                  name: nameController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );
                context.read<MasterDataProvider>().updateSubject(updatedSubject);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddTeacherDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('教員を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final teacher = Teacher(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                );
                context.read<MasterDataProvider>().addTeacher(teacher);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, Teacher teacher) {
    final nameController = TextEditingController(text: teacher.name);
    final emailController = TextEditingController(text: teacher.email);
    final phoneController = TextEditingController(text: teacher.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('教員を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedTeacher = Teacher(
                  id: teacher.id,
                  name: nameController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                );
                context.read<MasterDataProvider>().updateTeacher(updatedTeacher);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final buildingController = TextEditingController();
    final floorController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('教室を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '教室名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: buildingController,
              decoration: const InputDecoration(
                labelText: '建物',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: floorController,
              decoration: const InputDecoration(
                labelText: '階',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: '収容人数',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final room = Room(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  building: buildingController.text.isEmpty ? null : buildingController.text,
                  floor: floorController.text.isEmpty ? null : int.tryParse(floorController.text),
                  capacity: capacityController.text.isEmpty ? null : int.tryParse(capacityController.text),
                );
                context.read<MasterDataProvider>().addRoom(room);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showEditRoomDialog(BuildContext context, Room room) {
    final nameController = TextEditingController(text: room.name);
    final buildingController = TextEditingController(text: room.building);
    final floorController = TextEditingController(
      text: room.floor?.toString() ?? '',
    );
    final capacityController = TextEditingController(
      text: room.capacity?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('教室を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '教室名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: buildingController,
              decoration: const InputDecoration(
                labelText: '建物',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: floorController,
              decoration: const InputDecoration(
                labelText: '階',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: '収容人数',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updatedRoom = Room(
                  id: room.id,
                  name: nameController.text,
                  building: buildingController.text.isEmpty ? null : buildingController.text,
                  floor: floorController.text.isEmpty ? null : int.tryParse(floorController.text),
                  capacity: capacityController.text.isEmpty ? null : int.tryParse(capacityController.text),
                );
                context.read<MasterDataProvider>().updateRoom(updatedRoom);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
} 