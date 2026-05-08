import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/theme/app_themes.dart';

class ThemeService {
  ThemeService._();

  static const String _settingsBox = 'settings';
  static const String _legacyThemeModeKey = 'theme_mode';
  static const String _themeKey = 'theme_preset';
  static const String _localeKey = 'locale_code';
  static const String _sleepTimeKey = 'sleep_time';
  static const String _wakeTimeKey = 'wake_time';
  static const String _dailyResetDateKey = 'daily_reset_date';
  static const String _pickTaskIntroSeenKey = 'pick_task_intro_seen';

  static late Box _settingsBoxInstance;
  static final Rx<AppThemePreset> currentTheme = AppThemePreset.royalIvory.obs;
  static Locale currentLocale = const Locale('tr');

  static Future<void> init() async {
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    final savedThemeKey = _settingsBoxInstance.get(_themeKey) as String?;
    currentTheme.value = _themeFromStorage(savedThemeKey);

    if (savedThemeKey == null) {
      final legacyThemeIndex = _settingsBoxInstance.get(_legacyThemeModeKey);
      if (legacyThemeIndex is int) {
        currentTheme.value = switch (ThemeMode.values[legacyThemeIndex]) {
          ThemeMode.dark => AppThemePreset.midnightBlack,
          ThemeMode.light => AppThemePreset.royalIvory,
          ThemeMode.system => AppThemePreset.royalIvory,
        };
      }
    }

    final localeCode = _settingsBoxInstance.get(_localeKey, defaultValue: 'tr');
    currentLocale = Locale(localeCode);
    Get.updateLocale(currentLocale);
  }

  static ThemeData get activeThemeData =>
      AppThemes.themeFor(currentTheme.value);

  static void changeTheme(AppThemePreset preset) {
    currentTheme.value = preset;
    _settingsBoxInstance.put(_themeKey, preset.name);
    Get.changeTheme(activeThemeData);
    Get.changeThemeMode(
      activeThemeData.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }

  static void changeLocale(Locale locale) {
    currentLocale = locale;
    _settingsBoxInstance.put(_localeKey, locale.languageCode);
    Get.updateLocale(locale);
  }

  static String? get sleepTimeString =>
      _settingsBoxInstance.get(_sleepTimeKey) as String?;

  static String? get wakeTimeString =>
      _settingsBoxInstance.get(_wakeTimeKey) as String?;

  static Future<void> saveSleepWakeTimes({
    required String sleepTime,
    required String wakeTime,
  }) async {
    await _settingsBoxInstance.put(_sleepTimeKey, sleepTime);
    await _settingsBoxInstance.put(_wakeTimeKey, wakeTime);
  }

  static String? get lastDailyResetDate =>
      _settingsBoxInstance.get(_dailyResetDateKey) as String?;

  static Future<void> saveLastDailyResetDate(String value) async {
    await _settingsBoxInstance.put(_dailyResetDateKey, value);
  }

  static bool get hasSeenPickTaskIntro =>
      _settingsBoxInstance.get(_pickTaskIntroSeenKey, defaultValue: false)
          as bool;

  static Future<void> markPickTaskIntroSeen() async {
    await _settingsBoxInstance.put(_pickTaskIntroSeenKey, true);
  }

  static AppThemePreset _themeFromStorage(String? value) {
    if (value == 'modernRed') {
      return AppThemePreset.midnightBlack;
    }

    return AppThemePreset.values.firstWhere(
      (preset) => preset.name == value,
      orElse: () => AppThemePreset.royalIvory,
    );
  }
}
