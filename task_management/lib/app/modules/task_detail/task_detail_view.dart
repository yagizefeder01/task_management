import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'task_detail_controller.dart';

class TaskDetailView extends GetView<TaskDetailController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('task_detail'.tr),
        actions: [
          Obx(() {
            if (controller.isEditing) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: controller.removeTask,
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'add_task'.tr,
                  hintText: 'title_hint'.tr,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text('priority'.tr),
              Obx(() => Slider(
                    value: controller.priority.value.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: controller.priority.value.toString(),
                    onChanged: (value) => controller.priority.value = value.toInt(),
                  )),
              const SizedBox(height: 12),
              Text('energy_level'.tr),
              Obx(() => Slider(
                    value: controller.energy.value.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: controller.energy.value.toString(),
                    onChanged: (value) => controller.energy.value = value.toInt(),
                  )),
              const SizedBox(height: 12),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${'due_date'.tr}: ${controller.dueDate.value.toLocal().toString().split(' ').first}'),
                      TextButton(
                        onPressed: () => controller.selectDueDate(context),
                        child: const Text('Select'),
                      ),
                    ],
                  )),
              const SizedBox(height: 12),
              Obx(() => SwitchListTile(
                    value: controller.isCompleted.value,
                    title: Text('completed'.tr),
                    onChanged: (value) => controller.isCompleted.value = value,
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.saveTask,
                child: Text('save'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
