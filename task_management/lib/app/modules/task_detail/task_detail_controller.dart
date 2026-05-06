import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/task_model.dart';
import '../../data/services/haptic_service.dart';
import '../../data/services/hive_service.dart';

class TaskDetailController extends GetxController {
  final titleController = TextEditingController();
  final priority = 1.obs;
  final energy = 1.obs;
  final isCompleted = false.obs;
  final dueDate = DateTime.now().obs;

  TaskModel? task;

  bool get isEditing => task != null;

  @override
  void onInit() {
    super.onInit();
    task = Get.arguments as TaskModel?;
    if (task != null) {
      titleController.text = task!.title;
      priority.value = task!.priority;
      energy.value = task!.energyLevel;
      isCompleted.value = task!.isCompleted;
      dueDate.value = task!.dueDate;
    }
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('error', 'enter_title_error'.tr);
      return;
    }

    await HiveService.init();

    if (isEditing) {
      task!
        ..title = title
        ..priority = priority.value
        ..energyLevel = energy.value
        ..isCompleted = isCompleted.value
        ..dueDate = dueDate.value;
      await HiveService.updateTask(task!);
      await HapticService.vibration();
      Get.back(result: true);
      return;
    }

    final newTask = TaskModel(
      title: title,
      priority: priority.value,
      energyLevel: energy.value,
      isCompleted: isCompleted.value,
      dueDate: dueDate.value,
    );
    await HiveService.addTask(newTask);
    await HapticService.vibration();
    Get.back(result: true);
  }

  Future<void> removeTask() async {
    if (!isEditing) {
      return;
    }

    await HiveService.deleteTask(task!);
    await HapticService.vibration();
    Get.back(result: true);
  }

  Future<void> selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      dueDate.value = picked;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}
