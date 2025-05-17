import 'package:flutter_test/flutter_test.dart';
import 'package:tabulist/services/ads_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

@GenerateMocks([SharedPreferences])
import 'ads_service_test.mocks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late MockSharedPreferences mockPrefs;

  setUp(() {
    AdsService.resetForTest();
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getBool(any)).thenReturn(true);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
  });

  group('AdsService Tests', () {
    test('初期化時に広告が有効', () async {
      await AdsService.initialize(
        skipMobileAdsInit: true,
        prefs: mockPrefs,
      );
      expect(AdsService.isEnabled, true);
      verify(mockPrefs.getBool(any)).called(1);
    });

    test('広告の有効/無効を切り替えられる', () async {
      await AdsService.initialize(
        skipMobileAdsInit: true,
        prefs: mockPrefs,
      );
      expect(AdsService.isEnabled, true);

      await AdsService.setEnabled(false);
      expect(AdsService.isEnabled, false);
      verify(mockPrefs.setBool(any, false)).called(1);

      await AdsService.setEnabled(true);
      expect(AdsService.isEnabled, true);
      verify(mockPrefs.setBool(any, true)).called(1);
    });

    test('バナー広告を作成できる', () {
      final ad = AdsService.createBannerAd();
      expect(ad, isNotNull);
    });
  });
} 