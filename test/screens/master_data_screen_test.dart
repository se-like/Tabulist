import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/master_data_screen.dart';
import 'package:mockito/annotations.dart';
import 'master_data_screen_test.mocks.dart';

@GenerateMocks([MasterDataProvider])
void main() {
  late MockMasterDataProvider mockMasterDataProvider;

  setUp(() {
    mockMasterDataProvider = MockMasterDataProvider();

    when(mockMasterDataProvider.subjects).thenReturn([
      Subject(id: 'sub1', name: '数学'),
      Subject(id: 'sub2', name: '英語'),
    ]);
    when(mockMasterDataProvider.teachers).thenReturn([
      Teacher(id: 't1', name: '山田先生'),
      Teacher(id: 't2', name: '鈴木先生'),
    ]);
    when(mockMasterDataProvider.rooms).thenReturn([
      Room(id: 'r1', name: '101教室'),
      Room(id: 'r2', name: '102教室'),
    ]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(value: mockMasterDataProvider),
        ],
        child: const MasterDataScreen(),
      ),
    );
  }

  testWidgets('マスターデータ画面が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('マスターデータ'), findsOneWidget);
    expect(find.text('科目'), findsOneWidget);
    expect(find.text('教員'), findsOneWidget);
    expect(find.text('教室'), findsOneWidget);
  });

  testWidgets('科目一覧が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('数学'), findsOneWidget);
    expect(find.text('英語'), findsOneWidget);
  });

  testWidgets('教員一覧が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('山田先生'), findsOneWidget);
    expect(find.text('鈴木先生'), findsOneWidget);
  });

  testWidgets('教室一覧が正しく表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('101教室'), findsOneWidget);
    expect(find.text('102教室'), findsOneWidget);
  });

  testWidgets('科目追加ボタンが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNWidgets(3)); // 科目、教員、教室の追加ボタン
  });

  testWidgets('科目の編集が正しく動作する', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    expect(find.text('科目を編集'), findsOneWidget);
  });

  testWidgets('科目の削除が正しく動作する', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(find.text('科目を削除'), findsOneWidget);
    expect(find.text('この科目を削除してもよろしいですか？'), findsOneWidget);
  });
} 