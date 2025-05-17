import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsService {
  static const String _adsEnabledKey = 'ads_enabled';
  static bool _isInitialized = false;
  static bool _adsEnabled = true;
  static SharedPreferences? _prefs;

  static Future<void> initialize({
    bool skipMobileAdsInit = false,
    SharedPreferences? prefs,
  }) async {
    if (!_isInitialized) {
      if (!skipMobileAdsInit) {
        await MobileAds.instance.initialize();
      }
      _prefs = prefs ?? await SharedPreferences.getInstance();
      _adsEnabled = _prefs?.getBool(_adsEnabledKey) ?? true;
      _isInitialized = true;
    }
  }

  static bool get isAdsEnabled => _adsEnabled;

  static Future<void> setAdsEnabled(bool enabled) async {
    _adsEnabled = enabled;
    if (_prefs == null) {
      // テストや初期化漏れ時は何もしない（例外を投げてもよいが、ここでは何もしない）
      return;
    }
    await _prefs!.setBool(_adsEnabledKey, enabled);
  }

  // テスト用のエイリアス
  static bool get isEnabled => isAdsEnabled;
  static Future<void> setEnabled(bool enabled) => setAdsEnabled(enabled);

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-4895158562186219/6897495503',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  static void resetForTest() {
    _isInitialized = false;
    _adsEnabled = true;
    _prefs = null;
  }
} 