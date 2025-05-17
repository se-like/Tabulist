import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tabulist/models/master_data.dart';
import 'package:tabulist/providers/master_data_provider.dart';
import 'package:tabulist/screens/master_data_edit_screen.dart';
import 'package:mockito/annotations.dart';
import 'master_data_edit_screen_test.mocks.dart';

@GenerateMocks([MasterDataProvider])
void main() {
  late MockMasterDataProvider mockMasterDataProvider;

  setUp(() {
    mockMasterDataProvider = MockMasterDataProvider();
    when(mockMasterDataProvider.addSubject(any)).thenAnswer((_) async => Future.value());
    when(mockMasterDataProvider.updateSubject(any)).thenAnswer((_) async => Future.value());
    when(mockMasterDataProvider.addTeacher(any)).thenAnswer((_) async => Future.value());
    when(mockMasterDataProvider.updateTeacher(any)).thenAnswer((_) async => Future.value());
    when(mockMasterDataProvider.addRoom(any)).thenAnswer((_) async => Future.value());
    when(mockMasterDataProvider.updateRoom(any)).thenAnswer((_) async => Future.value());
  });

  Widget createWidgetUnderTest({
    required MasterDataType type,
    dynamic item,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MasterDataProvider>.value(value: mockMasterDataProvider),
        ],
        child: MasterDataEditScreen(
          type: type,
          item: item,
        ),
      ),
    );
  }

  group('科目編集画面のテスト', () {
    testWidgets('新規科目追加画面が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.subject,
      ));
      await tester.pumpAndSettle();

      expect(find.text('科目を追加'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('科目編集画面が正しく表示される', (WidgetTester tester) async {
      final subject = Subject(id: '1', name: '数学');
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.subject,
        item: subject,
      ));
      await tester.pumpAndSettle();

      expect(find.text('科目を編集'), findsOneWidget);
      expect(find.text('数学'), findsOneWidget);
    });

    testWidgets('科目の保存が正しく動作する', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.subject,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '新しい科目');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      verify(mockMasterDataProvider.addSubject(any)).called(1);
    });
  });

  group('教員編集画面のテスト', () {
    testWidgets('新規教員追加画面が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.teacher,
      ));
      await tester.pumpAndSettle();

      expect(find.text('教員を追加'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3)); // 名前、メール、電話
    });

    testWidgets('教員編集画面が正しく表示される', (WidgetTester tester) async {
      final teacher = Teacher(
        id: '1',
        name: '山田先生',
        email: 'yamada@example.com',
        phone: '090-1234-5678',
      );
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.teacher,
        item: teacher,
      ));
      await tester.pumpAndSettle();

      expect(find.text('教員を編集'), findsOneWidget);
      expect(find.text('山田先生'), findsOneWidget);
      expect(find.text('yamada@example.com'), findsOneWidget);
      expect(find.text('090-1234-5678'), findsOneWidget);
    });

    testWidgets('教員の保存が正しく動作する', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.teacher,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '新しい教員');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      verify(mockMasterDataProvider.addTeacher(any)).called(1);
    });
  });

  group('教室編集画面のテスト', () {
    testWidgets('新規教室追加画面が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.room,
      ));
      await tester.pumpAndSettle();

      expect(find.text('教室を追加'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // 名前、建物、階、収容人数
    });

    testWidgets('教室編集画面が正しく表示される', (WidgetTester tester) async {
      final room = Room(
        id: '1',
        name: '101教室',
        building: '本館',
        floor: 1,
        capacity: 40,
      );
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.room,
        item: room,
      ));
      await tester.pumpAndSettle();

      expect(find.text('教室を編集'), findsOneWidget);
      expect(find.text('101教室'), findsOneWidget);
      expect(find.text('本館'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('教室の保存が正しく動作する', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        type: MasterDataType.room,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '新しい教室');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      verify(mockMasterDataProvider.addRoom(any)).called(1);
    });
  });
} 