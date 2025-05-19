import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';

class AdsService {
  static const String _adsEnabledKey = 'ads_enabled';
  static bool _isInitialized = false;
  static bool _adsEnabled = true;
  static SharedPreferences? _prefs;
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';  // テスト用広告ユニットID
  static BannerAd? _bannerAd;
  static bool _isAdLoaded = false;
  static Timer? _initTimer;
  static Timer? _loadTimer;
  static int _retryCount = 0;
  static const int _maxRetries = 3;

  static Future<void> initialize({
    bool skipMobileAdsInit = false,
    SharedPreferences? prefs,
  }) async {
    print('AdsService.initialize 開始: _isInitialized = $_isInitialized');
    try {
      if (!_isInitialized) {
        if (!skipMobileAdsInit) {
          print('MobileAdsの初期化を開始');
          try {
            await MobileAds.instance.initialize();
            print('MobileAds.instance.initialize() 完了');
          } catch (e) {
            print('MobileAdsの初期化でエラーが発生: $e');
            rethrow;
          }
          
          print('RequestConfigurationの設定開始');
          try {
            MobileAds.instance.updateRequestConfiguration(
              RequestConfiguration(
                testDeviceIds: [
                  '3757D847-0E61-43C2-BDFC-E4F1FB004BB9',
                  '2589D37C-B675-4FC2-9544-08438959B91D',
                  '00008112-001C39593EB8A01E',
                ],
              ),
            );
            print('RequestConfigurationの設定完了');
          } catch (e) {
            print('RequestConfigurationの設定でエラーが発生: $e');
            rethrow;
          }
          print('MobileAdsの初期化完了');
        }

        try {
          _prefs = prefs ?? await SharedPreferences.getInstance();
          _adsEnabled = true;
          await _prefs?.setBool(_adsEnabledKey, true);
          print('広告の設定を強制的に有効化: _adsEnabled = $_adsEnabled');
          _isInitialized = true;
        } catch (e) {
          print('SharedPreferencesの初期化でエラーが発生: $e');
          rethrow;
        }
      }
      print('AdsService.initialize 完了: _isInitialized = $_isInitialized, _adsEnabled = $_adsEnabled');
    } catch (e, stackTrace) {
      print('AdsServiceの初期化中にエラーが発生:');
      print('- エラー: $e');
      print('- スタックトレース: $stackTrace');
      rethrow;
    }
  }

  static bool get isAdsEnabled {
    print('isAdsEnabled 呼び出し: _adsEnabled = $_adsEnabled');
    return _adsEnabled;
  }

  static Future<void> setAdsEnabled(bool enabled) async {
    print('setAdsEnabled 呼び出し: enabled = $enabled');
    _adsEnabled = enabled;
    if (_prefs == null) {
      print('警告: _prefs が null です');
      return;
    }
    await _prefs!.setBool(_adsEnabledKey, enabled);
    print('広告の設定を保存: _adsEnabled = $_adsEnabled');
  }

  static bool get isEnabled => isAdsEnabled;
  static Future<void> setEnabled(bool enabled) => setAdsEnabled(enabled);

  static Future<void> createBannerAd({VoidCallback? onLoaded}) async {
    if (!_adsEnabled) {
      print('広告が無効化されているため、バナー広告を作成しません');
      return;
    }

    try {
      // 既存の広告を破棄
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;

      print('バナー広告の作成処理開始');
      print('広告ユニットID: $_bannerAdUnitId');
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('バナー広告の読み込み成功');
            print('- 広告ユニットID: ${ad.adUnitId}');
            _isAdLoaded = true;
            _bannerAd = ad as BannerAd;
            if (onLoaded != null) onLoaded();
          },
          onAdFailedToLoad: (ad, error) {
            print('バナー広告の読み込み失敗:');
            print('- 広告ユニットID: ${ad.adUnitId}');
            print('- エラーコード: ${error.code}');
            print('- エラーメッセージ: ${error.message}');
            print('- エラードメイン: ${error.domain}');
            _isAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            
            // 再試行回数が上限に達していない場合のみ再試行
            if (_retryCount < _maxRetries) {
              _retryCount++;
              print('広告の再読み込みを試みます（試行回数: $_retryCount/$_maxRetries）');
              Future.delayed(const Duration(seconds: 2), () {
                if (_adsEnabled) {
                  createBannerAd(onLoaded: onLoaded);
                }
              });
            } else {
              print('最大再試行回数に達したため、広告の読み込みを中止します');
              _retryCount = 0;  // リトライカウントをリセット
            }
          },
          onAdOpened: (ad) {
            print('広告が開かれました');
          },
          onAdClosed: (ad) {
            print('広告が閉じられました');
          },
          onAdImpression: (ad) {
            print('広告のインプレッションが記録されました');
          },
        ),
      );

      print('バナー広告のインスタンス生成完了');
      await _bannerAd?.load();
    } catch (e, stackTrace) {
      print('広告の作成中にエラーが発生しました:');
      print('- エラー: $e');
      print('- スタックトレース: $stackTrace');
      _isAdLoaded = false;
    }
  }

  static Widget _showBannerAd() {
    if (_bannerAd == null || !_isAdLoaded) {
      print('広告の表示に必要な条件が満たされていません: _bannerAd = $_bannerAd, _isAdLoaded = $_isAdLoaded');
      return const SizedBox.shrink();
    }
    print('広告の表示処理を実行: _bannerAd = $_bannerAd');
    return AdWidget(ad: _bannerAd!);
  }

  static Widget getBannerAdWidget() {
    if (_bannerAd == null || !_isAdLoaded) {
      print('広告ウィジェットの取得: 広告が読み込まれていません');
      print('- _bannerAd: $_bannerAd');
      print('- _isAdLoaded: $_isAdLoaded');
      return const SizedBox.shrink();
    }
    print('広告ウィジェットの取得: 広告を表示します');
    return _showBannerAd();
  }

  static void dispose() {
    _initTimer?.cancel();
    _loadTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    _retryCount = 0;  // リトライカウントをリセット
  }

  static void resetForTest() {
    _isInitialized = false;
    _adsEnabled = true;
    _prefs = null;
    dispose();
  }

  static bool get isAdLoaded => _isAdLoaded;
} 