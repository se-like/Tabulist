import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/timetable_provider.dart';
import '../models/class.dart';
import '../providers/master_data_provider.dart';
import '../models/master_data.dart';
import '../services/ads_service.dart';
import '../providers/period_master_provider.dart';
import '../models/period_master.dart';
import '../screens/add_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TimetableProvider _timetableProvider;
  late PeriodMasterProvider _periodMasterProvider;
  late MasterDataProvider _masterDataProvider;
  // 現在の曜日を初期値として設定（1-7、月曜日が1）
  int _selectedDay = DateTime.now().weekday - 1;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
    _periodMasterProvider = Provider.of<PeriodMasterProvider>(context, listen: false);
    _masterDataProvider = Provider.of<MasterDataProvider>(context, listen: false);
    if (AdsService.isAdsEnabled) {
      _bannerAd = AdsService.createBannerAd()
        ..load().then((_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabulist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/period-master');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final periodMasterProvider = Provider.of<PeriodMasterProvider>(context, listen: false);
              if (!periodMasterProvider.isInitialized) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('時限マスターの初期化が必要です'),
                    content: const Text('時限マスターの初期化が完了していません。しばらく待ってから再試行してください。'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
                return;
              }
              final periodMaster = periodMasterProvider.getPeriodMasterByDay(_selectedDay + 1);
              
              if (periodMaster == null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('時限マスターの設定が必要です'),
                    content: const Text('授業を登録する前に、時限マスターを設定してください。'),
                    actions: [
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('時限マスターを設定'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/period-master');
                        },
                      ),
                    ],
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddClassScreen(
                    periodNumber: 1,
                    dayOfWeek: _selectedDay + 1,
                  ),
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
          if (AdsService.isAdsEnabled && _isAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              alignment: Alignment.center,
              child: AdWidget(ad: _bannerAd!),
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
                // 土日をタップした場合は月曜日を選択
                _selectedDay = index >= 5 ? 0 : index;
              });
              // TimetableProviderのcurrentDayOfWeekを更新
              final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
              timetableProvider.setCurrentDayOfWeek(_selectedDay + 1);
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
    if (_selectedDay >= 5) {
      return const SizedBox.shrink();
    }
    return Consumer3<TimetableProvider, MasterDataProvider, PeriodMasterProvider>(
      builder: (context, timetableProvider, masterDataProvider, periodMasterProvider, child) {
        print('ホーム画面: _buildTimetable開始');
        print('ホーム画面: _selectedDay = $_selectedDay');
        
        if (!periodMasterProvider.isInitialized) {
          print('ホーム画面: periodMasterProviderが初期化されていません');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        print('ホーム画面: getPeriodMasterByDay呼び出し前');
        print('ホーム画面: 渡すday = ${_selectedDay + 1}');
        final periodMaster = periodMasterProvider.getPeriodMasterByDay(_selectedDay + 1);
        print('ホーム画面: getPeriodMasterByDay呼び出し後');
        print('ホーム画面: periodMaster = $periodMaster');
        print('ホーム画面: periodMasters = ${periodMasterProvider.periodMasters}');
        print('ホーム画面: periodMasters dayOfWeek = ${periodMasterProvider.periodMasters.map((m) => m.dayOfWeek).toList()}');

        if (periodMaster == null) {
          print('ホーム画面: periodMasterがnullです');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('時限マスターが設定されていません'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/period-master');
                  },
                  child: const Text('時限マスターを設定'),
                ),
              ],
            ),
          );
        }

        print('ホーム画面: periodMasterのperiods = ${periodMaster.periods}');
        return ListView.builder(
          itemCount: periodMaster.periods.length,
          itemBuilder: (context, index) {
            final period = periodMaster.periods[index];
            print('ホーム画面: 時限${period.periodNumber}の処理開始');
            final classItem = timetableProvider.getClassByPeriod(
              _selectedDay + 1,
              period.periodNumber,
            );
            print('ホーム画面: 時限${period.periodNumber}のclassItem = $classItem');

            if (!period.isEnabled) {
              print('ホーム画面: 時限${period.periodNumber}は無効');
              return _buildDisabledPeriodSlot(period, periodMaster);
            }

            if (classItem == null) {
              print('ホーム画面: 時限${period.periodNumber}は空き');
              return _buildEmptyPeriodSlot(period, periodMaster);
            }

            print('ホーム画面: 時限${period.periodNumber}に授業あり');
            return _buildClassSlot(
              context,
              classItem,
              masterDataProvider,
              period,
              periodMaster,
            );
          },
        );
      },
    );
  }

  Widget _buildDisabledPeriodSlot(Period period, PeriodMaster periodMaster) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${period.periodNumber}時限目',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPeriodSlot(Period period, PeriodMaster periodMaster) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddClassScreen(
              periodNumber: period.periodNumber,
              dayOfWeek: _selectedDay + 1,
            ),
          ),
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            '${period.periodNumber}時限目',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassSlot(
    BuildContext context,
    Class classItem,
    MasterDataProvider masterDataProvider,
    Period period,
    PeriodMaster periodMaster,
  ) {
    print('ホーム画面: _buildClassSlot開始');
    print('ホーム画面: classItem.isActive = ${classItem.isActive}');
    print('ホーム画面: classItem.subjectId = ${classItem.subjectId}');
    print('ホーム画面: classItem.teacherId = ${classItem.teacherId}');
    print('ホーム画面: classItem.roomId = ${classItem.roomId}');

    final subject = masterDataProvider.subjects.firstWhere(
      (s) => s.id == classItem.subjectId,
      orElse: () => Subject(id: '', name: ''),
    );
    final teacher = masterDataProvider.teachers.firstWhere(
      (t) => t.id == classItem.teacherId,
      orElse: () => Teacher(id: '', name: ''),
    );
    final room = masterDataProvider.rooms.firstWhere(
      (r) => r.id == classItem.roomId,
      orElse: () => Room(id: '', name: ''),
    );

    print('ホーム画面: subject.name = ${subject.name}');
    print('ホーム画面: teacher.name = ${teacher.name}');
    print('ホーム画面: room.name = ${room.name}');

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/edit-class',
          arguments: classItem,
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: classItem.isActive ? Colors.white : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: classItem.isActive
            ? ListTile(
                title: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${teacher.name} / ${room.name}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  '${period.periodNumber}時限目',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Center(
                child: Text(
                  '${period.periodNumber}時限目',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
