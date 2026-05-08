import 'package:get/get.dart';

import '../../modules/home/home_controller.dart';
import 'hive_service.dart';
import 'theme_service.dart';

class DailyTaskResetService {
  DailyTaskResetService._();

  static Future<bool> ensureResetIfNeeded() async {
    await HiveService.init();

    final resetKey = _dateKey(DateTime.now());
    if (ThemeService.lastDailyResetDate == resetKey) {
      return false;
    }

    var changed = false;
    for (final task in HiveService.getTasks()) {
      if (!task.isCompleted) {
        continue;
      }

      task.isCompleted = false;
      await HiveService.updateTask(task);
      changed = true;
    }

    await ThemeService.saveLastDailyResetDate(resetKey);
    return changed;
  }

  static Future<void> refreshHomeIfOpen() async {
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    final controller = Get.find<HomeController>();
    controller.tasks.assignAll(HiveService.getTasks());
  }

  static String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
