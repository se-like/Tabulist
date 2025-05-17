import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'screens/home_screen.dart';
import 'screens/add_class_screen.dart';
import 'screens/master_data_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/master_data_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/period_master_provider.dart';
import 'screens/edit_class_screen.dart';
import 'screens/period_master_screen.dart';
import 'services/ads_service.dart';
import 'services/purchase_service.dart';
import 'theme/app_theme.dart';
import 'models/master_data.dart';
import 'models/class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final masterDataProvider = MasterDataProvider(prefs: prefs);
    final timetableProvider = TimetableProvider(prefs: prefs);
    final periodMasterProvider = PeriodMasterProvider(prefs: prefs);

    // 各プロバイダーの初期化を待機
    await Future.wait([
      masterDataProvider.loadMasterData(),
      timetableProvider.initialize(),
      periodMasterProvider.initialize(),
    ]);

    // 初期化の結果を確認
    if (!masterDataProvider.isInitialized || 
        !timetableProvider.isInitialized || 
        !periodMasterProvider.isInitialized) {
      throw Exception('プロバイダーの初期化に失敗しました');
    }

    // テーマの初期化
    await AppTheme.initialize();
    
    // 通知の初期化
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // 通知タップ時の処理
      },
    );

    // 広告の初期化
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['3757D847-0E61-43C2-BDFC-E4F1FB004BB9'],
        ),
      );
      await AdsService.initialize(prefs: prefs);
    } catch (e) {
      print('広告の初期化中にエラーが発生しました: $e');
    }
    
    // 課金の初期化
    await PurchaseService.initialize();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: masterDataProvider),
          ChangeNotifierProvider.value(value: timetableProvider),
          ChangeNotifierProvider.value(value: periodMasterProvider),
        ],
        child: MyApp(prefs: prefs),
      ),
    );
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    // エラーが発生してもアプリは起動
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('初期化中にエラーが発生しました'),
                const SizedBox(height: 16),
                Text(e.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // アプリを再起動
                    main();
                  },
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabulist',
      theme: AppTheme.currentTheme,
      home: const MainScreen(),
      routes: {
        '/add-class': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is int) {
            return AddClassScreen(periodNumber: args, dayOfWeek: 1);
          } else if (args is Map<String, dynamic>) {
            return AddClassScreen(
              periodNumber: args['periodNumber'] ?? 1,
              dayOfWeek: args['dayOfWeek'] ?? 1,
            );
          }
          throw Exception('Invalid arguments format');
        },
        '/edit-class': (context) {
          final classItem = ModalRoute.of(context)!.settings.arguments as Class;
          return EditClassScreen(classItem: classItem);
        },
        '/period-master': (context) => const PeriodMasterScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MasterDataScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: '時間割',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'マスター',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddClassScreen(
                      periodNumber: 1,
                      dayOfWeek: 1,  // デフォルトで月曜日
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
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
}
