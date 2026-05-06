import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_title'.tr),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            onSelected: (value) {
              if (value == 'priority') {
                controller.changeFilter(TaskFilter.priority);
              } else if (value == 'energy') {
                controller.changeFilter(TaskFilter.energy);
              } else {
                controller.changeFilter(TaskFilter.none);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'none', child: Text('filter_none'.tr)),
              PopupMenuItem(value: 'priority', child: Text('filter_priority'.tr)),
              PopupMenuItem(value: 'energy', child: Text('filter_energy'.tr)),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: controller.changeLocale,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'tr', child: const Text('Türkçe')),
              PopupMenuItem(value: 'en', child: const Text('English')),
              PopupMenuItem(value: 'zh', child: const Text('中文')),
              PopupMenuItem(value: 'hi', child: const Text('हिंदी')),
              PopupMenuItem(value: 'es', child: const Text('Español')),
              PopupMenuItem(value: 'pt', child: const Text('Português')),
              PopupMenuItem(value: 'fr', child: const Text('Français')),
              PopupMenuItem(value: 'ar', child: const Text('العربية')),
              PopupMenuItem(value: 'ru', child: const Text('Русский')),
              PopupMenuItem(value: 'de', child: const Text('Deutsch')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.primaryAction),
                  const SizedBox(width: 12),
                  Expanded(child: Text('local_storage_info'.tr)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = controller.filteredTasks;
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'no_tasks'.tr,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => controller.toggleComplete(task),
                        ),
                        title: Text(task.title),
                        subtitle: Text(
                          '${'priority'.tr}: ${task.priority} • ${'energy_level'.tr}: ${task.energyLevel} • ${'due_date'.tr}: ${task.dueDate.toLocal().toString().split(' ').first}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.removeTask(task),
                        ),
                        onTap: () => controller.editTask(task),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.taskDetail)?.then((_) => controller.loadTasks()),
        tooltip: 'add_task'.tr,
        child: const Icon(Icons.add),
      ),
    );
  }
}
