import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ads_service.dart';

class PurchaseService {
  static const String _removeAdsProductId = 'remove_ads';
  static const String _purchasedKey = 'purchased_remove_ads';
  static bool _isInitialized = false;
  static bool _hasPurchased = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      _hasPurchased = prefs.getBool(_purchasedKey) ?? false;
      if (_hasPurchased) {
        await AdsService.setAdsEnabled(false);
      }
      _isInitialized = true;
    }
  }

  static bool get hasPurchasedRemoveAds => _hasPurchased;

  static Future<void> purchaseRemoveAds() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      return;
    }

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({_removeAdsProductId});

    if (response.notFoundIDs.isNotEmpty) {
      return;
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);

    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // エラー処理
    }
  }

  static Future<void> handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      if (purchaseDetails.productID == _removeAdsProductId) {
        _hasPurchased = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_purchasedKey, true);
        await AdsService.setAdsEnabled(false);
      }
    }
  }
} 