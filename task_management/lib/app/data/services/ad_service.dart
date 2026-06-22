import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import '../../core/ads/ad_constants.dart';

class AdService {
  AdService._();

  static const String _boxName = 'ad_metrics';
  static const String _taskCreatedCountKey = 'task_created_count';
  static const String _bookSavedCountKey = 'book_saved_count';
  static const String _periodicItemCreatedCountKey =
      'periodic_item_created_count';
  static const int _taskInterstitialInterval = 4;
  static const int _bookInterstitialInterval = 3;
  static const int _periodicInterstitialInterval = 2;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  static Box<dynamic>? _box;
  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static bool _showInterstitialWhenReady = false;
  static bool _isShowingInterstitial = false;
  static DateTime? _lastInterstitialShownAt;
  static Timer? _cooldownTimer;

  static Future<void> initialize() async {
    if (!AdConstants.isSupportedPlatform) {
      return;
    }

    _box ??= await Hive.openBox(_boxName);
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  static Future<void> registerTaskCreated() async {
    if (!AdConstants.isSupportedPlatform) {
      return;
    }

    await _registerCountBasedTrigger(
      key: _taskCreatedCountKey,
      interval: _taskInterstitialInterval,
    );
  }

  static Future<void> registerBookSaved() async {
    if (!AdConstants.isSupportedPlatform) {
      return;
    }

    await _registerCountBasedTrigger(
      key: _bookSavedCountKey,
      interval: _bookInterstitialInterval,
    );
  }

  static Future<void> registerPeriodicItemCreated() async {
    if (!AdConstants.isSupportedPlatform) {
      return;
    }

    await _registerCountBasedTrigger(
      key: _periodicItemCreatedCountKey,
      interval: _periodicInterstitialInterval,
    );
  }

  static Future<void> showInterstitialIfReady() async {
    if (!AdConstants.isSupportedPlatform) {
      return;
    }

    if (_isShowingInterstitial) {
      _showInterstitialWhenReady = true;
      return;
    }

    if (!_isCooldownComplete) {
      _showInterstitialWhenReady = true;
      _scheduleCooldownRetry();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _showInterstitialWhenReady = true;
      _loadInterstitial();
      return;
    }

    _interstitialAd = null;
    _isShowingInterstitial = true;
    _showInterstitialWhenReady = false;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingInterstitial = false;
        _lastInterstitialShownAt = DateTime.now();
        ad.dispose();
        _loadInterstitial();
        _scheduleCooldownRetry();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingInterstitial = false;
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  static void _loadInterstitial() {
    final unitId = AdConstants.interstitialUnitId;
    if (!AdConstants.isSupportedPlatform ||
        unitId == null ||
        _isLoadingInterstitial) {
      return;
    }

    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _isLoadingInterstitial = false;

          if (_showInterstitialWhenReady &&
              !_isShowingInterstitial &&
              _isCooldownComplete) {
            showInterstitialIfReady();
          }
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  static bool get _isCooldownComplete {
    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt == null) {
      return true;
    }

    return DateTime.now().difference(lastShownAt) >= _interstitialCooldown;
  }

  static void _scheduleCooldownRetry() {
    if (!_showInterstitialWhenReady ||
        _isShowingInterstitial ||
        _isCooldownComplete) {
      return;
    }

    if (_cooldownTimer?.isActive ?? false) {
      return;
    }

    final lastShownAt = _lastInterstitialShownAt;
    if (lastShownAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(lastShownAt);
    final remaining = _interstitialCooldown - elapsed;
    if (remaining <= Duration.zero) {
      showInterstitialIfReady();
      return;
    }

    _cooldownTimer = Timer(remaining, () {
      _cooldownTimer = null;
      if (_showInterstitialWhenReady && !_isShowingInterstitial) {
        showInterstitialIfReady();
      }
    });
  }

  static Future<void> _registerCountBasedTrigger({
    required String key,
    required int interval,
  }) async {
    _box ??= await Hive.openBox(_boxName);

    final currentCount = (_box!.get(key, defaultValue: 0) as int?) ?? 0;
    final nextCount = currentCount + 1;
    await _box!.put(key, nextCount);

    if (nextCount % interval == 0) {
      await showInterstitialIfReady();
    }
  }
}
