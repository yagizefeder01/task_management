import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_date_picker_sheet.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/task_model.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/hive_service.dart';
import '../home/home_controller.dart';

class TaskDetailController extends GetxController {
  final titleController = TextEditingController();
  final titleText = ''.obs;
  final priority = 1.obs;
  final isCompleted = false.obs;
  final dueDate = Rxn<DateTime>();

  String get priorityLabel {
    switch (priority.value) {
      case 1:
        return 'priority_level_1'.tr;
      case 2:
        return 'priority_level_2'.tr;
      default:
        return 'priority_level_3'.tr;
    }
  }

  TaskModel? task;

  bool get isEditing => task != null;
  bool get canSave =>
      titleText.value.trim().isNotEmpty && dueDate.value != null;

  String get relativeDateLabel {
    final selected = dueDate.value;
    if (selected == null) {
      return '';
    }
    final start = DateTime(selected.year, selected.month, selected.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    return diff <= 0 ? 'started_today'.tr : '$diff ${'days_ago'.tr}';
  }

  int _normalizePriority(int value) {
    if (value <= 1) return 1;
    if (value == 2) return 2;
    return 3;
  }

  @override
  void onInit() {
    super.onInit();
    task = Get.arguments as TaskModel?;
    if (task != null) {
      titleController.text = task!.title;
      titleText.value = task!.title;
      priority.value = _normalizePriority(task!.priority);
      isCompleted.value = task!.isCompleted;
      dueDate.value = task!.dueDate;
    }

    titleController.addListener(_syncTitleText);
  }

  void _syncTitleText() {
    titleText.value = titleController.text;
  }

  Future<void> saveTask() async {
    final title = titleText.value.trim();
    if (title.isEmpty) {
      AppSnackbar.showError('task_detail'.tr, 'enter_title_error'.tr);
      return;
    }

    final selectedDueDate = dueDate.value;
    if (selectedDueDate == null) {
      AppSnackbar.showError('task_detail'.tr, 'Lutfen bir tarih secin');
      return;
    }

    await HiveService.init();
    final normalizedPriority = _normalizePriority(priority.value);

    if (isEditing) {
      task!
        ..title = title
        ..priority = normalizedPriority
        ..isCompleted = isCompleted.value
        ..dueDate = selectedDueDate;
      await HiveService.updateTask(task!);
      await HapticService.vibration();
      Get.back(result: true);
      AppSnackbar.showSuccess(title, 'save_success'.tr);
    } else {
      final newTask = TaskModel(
        title: title,
        priority: normalizedPriority,
        energyLevel: 1,
        isCompleted: isCompleted.value,
        dueDate: selectedDueDate,
      );
      await HiveService.addTask(newTask);
      task = newTask;
      await HapticService.vibration();
      Get.back(result: true);
      AppSnackbar.showSuccess(title, 'save_success'.tr);
    }
  }

  Future<void> removeTask() async {
    if (!isEditing) {
      Get.back(result: true);
      return;
    }

    final removedTask = TaskModel(
      title: task!.title,
      priority: task!.priority,
      energyLevel: task!.energyLevel,
      isCompleted: task!.isCompleted,
      dueDate: task!.dueDate,
    );

    await HiveService.deleteTask(task!);
    await HapticService.vibration();
    Get.back(result: true);
    AppSnackbar.showDelete(
      removedTask.title,
      'delete_success'.tr,
      onUndo: () async {
        await HiveService.addTask(removedTask);
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadTasks();
        }
      },
    );
  }

  Future<void> selectDueDate(BuildContext context) async {
    final picked = await AppDatePickerSheet.show(
      context,
      title: 'due_date'.tr,
      initialDate: dueDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      dueDate.value = picked;
    }
  }

  void setPriorityValue(int value) {
    priority.value = _normalizePriority(value);
  }

  void setDueDateFromNow(int days) {
    final now = DateTime.now();
    dueDate.value = DateTime(now.year, now.month, now.day + days);
  }

  @override
  void onClose() {
    titleController.removeListener(_syncTitleText);
    titleController.dispose();
    super.onClose();
  }
}
