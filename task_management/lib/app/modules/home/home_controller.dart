import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/task_model.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/theme_service.dart';
import '../../routes/app_routes.dart';

enum TaskFilter { none, priority, energy }

class HomeController extends GetxController {
  final tasks = <TaskModel>[].obs;
  final filter = TaskFilter.none.obs;
  final loading = false.obs;

  List<TaskModel> get filteredTasks {
    final list = tasks.toList();
    if (filter.value == TaskFilter.energy) {
      list.sort((a, b) => b.energyLevel.compareTo(a.energyLevel));
    } else if (filter.value == TaskFilter.priority) {
      list.sort((a, b) => b.priority.compareTo(a.priority));
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    loading.value = true;
    await HiveService.init();
    tasks.assignAll(HiveService.getTasks());
    loading.value = false;
  }

  void addTask() {
    Get.toNamed(AppRoutes.taskDetail)?.then((_) => loadTasks());
  }

  void editTask(TaskModel task) {
    Get.toNamed(AppRoutes.taskDetail, arguments: task)?.then((_) => loadTasks());
  }

  Future<void> toggleComplete(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await HiveService.updateTask(task);
    tasks.refresh();
    await HapticService.vibration();
  }

  Future<void> removeTask(TaskModel task) async {
    await HiveService.deleteTask(task);
    tasks.remove(task);
    await HapticService.vibration();
    Get.snackbar('delete', 'delete_success'.tr);
  }

  void changeFilter(TaskFilter type) {
    filter.value = type;
  }

  void changeTheme(ThemeMode mode) {
    ThemeService.changeTheme(mode);
  }

  void changeLocale(String code) {
    ThemeService.changeLocale(Locale(code));
  }
}
