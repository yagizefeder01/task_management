import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/services/theme_service.dart';

class SettingsController extends GetxController {
  final selectedTheme = ThemeService.currentTheme;
  final localeCode = ThemeService.currentLocale.languageCode.obs;
  final sleepTime = Rxn<TimeOfDay>();
  final wakeTime = Rxn<TimeOfDay>();

  @override
  void onInit() {
    super.onInit();
    sleepTime.value = _parseStoredTime(ThemeService.sleepTimeString);
    wakeTime.value = _parseStoredTime(ThemeService.wakeTimeString);
  }

  void changeTheme(AppThemePreset theme) {
    ThemeService.changeTheme(theme);
  }

  void changeLocale(String? code) {
    if (code == null) return;
    ThemeService.changeLocale(Locale(code));
    localeCode.value = code;
  }

  Future<void> saveDailyRhythm() async {
    final currentSleep = sleepTime.value;
    final currentWake = wakeTime.value;
    if (currentSleep == null || currentWake == null) {
      AppSnackbar.showError('settings_title'.tr, 'daily_rhythm_error'.tr);
      return;
    }

    await ThemeService.saveSleepWakeTimes(
      sleepTime: _formatStoredTime(currentSleep),
      wakeTime: _formatStoredTime(currentWake),
    );
    AppSnackbar.showSuccess('settings_title'.tr, 'settings_sleep_saved'.tr);
  }

  String formatTimeLabel(TimeOfDay? time) {
    if (time == null) {
      return '--:--';
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _parseStoredTime(String? value) {
    if (value == null || !value.contains(':')) {
      return null;
    }

    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatStoredTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
