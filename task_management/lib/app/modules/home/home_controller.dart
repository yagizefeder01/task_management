import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/task_model.dart';
import '../../data/services/daily_task_reset_service.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/theme_service.dart';
import '../../routes/app_routes.dart';

enum TaskFilter { none, priority }

class HomeController extends GetxController {
  final Random _random = Random();

  final tasks = <TaskModel>[].obs;
  final filter = TaskFilter.none.obs;
  final loading = false.obs;
  final dailyRhythmLoaded = false.obs;
  final sleepTime = Rxn<TimeOfDay>();
  final wakeTime = Rxn<TimeOfDay>();
  final showPickTaskIntro = false.obs;

  bool get needsDailyRhythmSetup =>
      sleepTime.value == null || wakeTime.value == null;

  List<TaskModel> get filteredTasks {
    final list = tasks.toList();
    list.sort((a, b) => b.priority.compareTo(a.priority));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    loading.value = true;
    dailyRhythmLoaded.value = false;
    await HiveService.init();
    _loadDailyRhythm();
    await DailyTaskResetService.ensureResetIfNeeded();
    tasks.assignAll(HiveService.getTasks());
    dailyRhythmLoaded.value = true;
    loading.value = false;
  }

  void _loadDailyRhythm() {
    sleepTime.value = _parseStoredTime(ThemeService.sleepTimeString);
    wakeTime.value = _parseStoredTime(ThemeService.wakeTimeString);
  }

  @override
  void onReady() {
    super.onReady();
    if (!ThemeService.hasSeenPickTaskIntro) {
      showPickTaskIntro.value = true;
    }
  }

  Future<void> saveDailyRhythm({
    required TimeOfDay sleep,
    required TimeOfDay wake,
  }) async {
    await ThemeService.saveSleepWakeTimes(
      sleepTime: _formatStoredTime(sleep),
      wakeTime: _formatStoredTime(wake),
    );
    sleepTime.value = sleep;
    wakeTime.value = wake;
    await DailyTaskResetService.ensureResetIfNeeded();
    tasks.assignAll(HiveService.getTasks());
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

  void addTask() {
    Get.toNamed(AppRoutes.taskDetail)?.then((_) => loadTasks());
  }

  void editTask(TaskModel task) {
    Get.toNamed(
      AppRoutes.taskDetail,
      arguments: task,
    )?.then((_) => loadTasks());
  }

  String getPriorityLabel(int value) {
    switch (value) {
      case 1:
        return 'priority_level_1'.tr;
      case 2:
        return 'priority_level_2'.tr;
      default:
        return 'priority_level_3'.tr;
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await HiveService.updateTask(task);
    tasks.refresh();
    await HapticService.vibration();
  }

  Future<void> removeTask(TaskModel task) async {
    final restoredTask = TaskModel(
      title: task.title,
      priority: task.priority,
      energyLevel: task.energyLevel,
      isCompleted: task.isCompleted,
      dueDate: task.dueDate,
    );
    await HiveService.deleteTask(task);
    tasks.remove(task);
    await HapticService.vibration();
    AppSnackbar.showDelete(
      task.title,
      'delete_success'.tr,
      onUndo: () async {
        await HiveService.addTask(restoredTask);
        await loadTasks();
      },
    );
  }

  void changeFilter(TaskFilter type) {
    filter.value = type;
  }

  void changeTheme(AppThemePreset theme) {
    ThemeService.changeTheme(theme);
  }

  void changeLocale(String code) {
    ThemeService.changeLocale(Locale(code));
  }

  Future<void> dismissPickTaskIntro() async {
    if (!showPickTaskIntro.value) {
      return;
    }

    showPickTaskIntro.value = false;
    await ThemeService.markPickTaskIntroSeen();
  }

  Future<TaskModel?> pickTaskForMe() async {
    final availableTasks = tasks
        .where((task) => !task.isCompleted)
        .toList(growable: false);

    if (availableTasks.isEmpty) {
      AppSnackbar.showError('home_title'.tr, 'pick_task_empty'.tr);
      return null;
    }

    final int highestPriority = availableTasks
        .map((task) => task.priority)
        .reduce((current, next) => current > next ? current : next);

    final topPriorityTasks = availableTasks
        .where((task) => task.priority == highestPriority)
        .toList(growable: false);

    final selectedTask =
        topPriorityTasks[_random.nextInt(topPriorityTasks.length)];

    return selectedTask;
  }
}
