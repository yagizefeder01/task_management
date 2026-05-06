import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeService {
  ThemeService._();

  static const String _settingsBox = 'settings';
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_code';

  static late Box _settingsBoxInstance;
  static ThemeMode themeMode = ThemeMode.system;
  static Locale currentLocale = const Locale('tr');

  static Future<void> init() async {
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    final themeIndex = _settingsBoxInstance.get(_themeKey, defaultValue: ThemeMode.system.index);
    themeMode = ThemeMode.values[themeIndex as int];

    final localeCode = _settingsBoxInstance.get(_localeKey, defaultValue: 'tr');
    currentLocale = Locale(localeCode);
    Get.updateLocale(currentLocale);
  }

  static void changeTheme(ThemeMode mode) {
    themeMode = mode;
    _settingsBoxInstance.put(_themeKey, mode.index);
    Get.changeThemeMode(mode);
  }

  static void changeLocale(Locale locale) {
    currentLocale = locale;
    _settingsBoxInstance.put(_localeKey, locale.languageCode);
    Get.updateLocale(locale);
  }
}
