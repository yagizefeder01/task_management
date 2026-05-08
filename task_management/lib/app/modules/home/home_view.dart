import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_side_drawer.dart';
import '../../data/models/task_model.dart';
import '../../data/services/theme_service.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _formatTaskDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
  }

  Future<void> _pickSleepOrWakeTime(
    BuildContext context, {
    required bool isSleep,
    required Rx<TimeOfDay?> target,
  }) async {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final TimeOfDay fallback = isSleep
        ? const TimeOfDay(hour: 23, minute: 0)
        : const TimeOfDay(hour: 7, minute: 0);
    final TimeOfDay initialTime = target.value ?? fallback;
    DateTime tempDateTime = DateTime(
      2024,
      1,
      1,
      initialTime.hour,
      initialTime.minute,
    );

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.semanticPalette.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final semantics = theme.semanticPalette;
        final accentColor = theme.colorScheme.secondary;
        final Color surfaceColor = theme.cardColor;
        final Color textColor = semantics.contrastForeground;
        final double maxSheetHeight =
            (MediaQuery.of(context).size.height * 0.56).clamp(300.0, 420.0);

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: maxSheetHeight,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(color: theme.surfaceBorderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: semantics.sheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      Text(
                        isSleep ? 'daily_sleep_time'.tr : 'daily_wake_time'.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('cancel'.tr),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                TimeOfDay(
                                  hour: tempDateTime.hour,
                                  minute: tempDateTime.minute,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark
                                  ? accentColor
                                  : theme.colorScheme.primary,
                              foregroundColor: theme.semanticPalette.onAccent,
                            ),
                            child: Text('save'.tr),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 216,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: isDark
                                ? Brightness.dark
                                : Brightness.light,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: tempDateTime,
                            use24hFormat: true,
                            onDateTimeChanged: (value) {
                              tempDateTime = value;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      target.value = picked;
    }
  }

  Future<void> _showMiniFocusMode(BuildContext context, TaskModel task) async {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final taskTone = theme.taskPalette.toneForPriority(task.priority);
    final Color accent = taskTone.accent;

    await Get.bottomSheet<void>(
      SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: theme.surfaceBorderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.surfaceBorderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'pick_task_mini_title'.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'pick_task_mini_body'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: isDark ? 0.72 : 0.64,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.toggleComplete(task);
                    if (context.mounted) {
                      Get.back<void>();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: theme.semanticPalette.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                    'pick_task_mini_complete'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back<void>();
                    controller.editTask(task);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(
                    'pick_task_mini_edit'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(
                    'pick_task_mini_back'.tr,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: theme.semanticPalette.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _showPickTaskFocusCard(
    BuildContext context,
    TaskModel task,
  ) async {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final currentTheme = ThemeService.currentTheme.value;
    final taskTone = theme.taskPalette.toneForPriority(task.priority);
    final accentAction = switch (currentTheme) {
      AppThemePreset.royalIvory => theme.colorScheme.primary,
      AppThemePreset.midnightBlack => AppThemes.iconPaletteFor(
        currentTheme,
      ).tasks,
      AppThemePreset.matteBlack => AppThemes.iconPaletteFor(currentTheme).tasks,
      AppThemePreset.carbonBlue => theme.colorScheme.primary,
    };
    final Color focusDialogBackground = theme.scaffoldBackgroundColor;
    final Color focusDialogCard = theme.cardColor;
    final Color focusDialogBorder = theme.surfaceBorderColor;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final Color primaryActionBackground =
        currentTheme == AppThemePreset.carbonBlue
        ? theme.colorScheme.primary
        : iconPalette.tasks;
    final Color primaryActionForeground = switch (currentTheme) {
      AppThemePreset.royalIvory => theme.semanticPalette.onAccent,
      AppThemePreset.midnightBlack =>
        (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      AppThemePreset.matteBlack => const Color(0xFF171717),
      AppThemePreset.carbonBlue => theme.semanticPalette.onAccent,
    };
    final Color dueDateBadgeBackground =
        currentTheme == AppThemePreset.midnightBlack
        ? accentAction.withValues(alpha: 0.24)
        : currentTheme == AppThemePreset.carbonBlue
        ? accentAction.withValues(alpha: 0.18)
        : accentAction.withValues(alpha: 0.16);
    final Color dueDateBadgeBorder =
        currentTheme == AppThemePreset.midnightBlack
        ? accentAction.withValues(alpha: 0.95)
        : accentAction.withValues(alpha: 0.38);
    final Color dueDateBadgeForeground = switch (currentTheme) {
      AppThemePreset.royalIvory => accentAction,
      AppThemePreset.midnightBlack => accentAction,
      AppThemePreset.matteBlack => accentAction,
      AppThemePreset.carbonBlue => accentAction,
    };
    final Color accent = taskTone.accent;

    await Get.dialog<void>(
      Dialog.fullscreen(
        backgroundColor: focusDialogBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                const Spacer(),
                Text(
                  'pick_task_focus_title'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: focusDialogCard,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: focusDialogBorder, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          color: accent,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        task.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _FocusBadge(
                            label: controller.getPriorityLabel(task.priority),
                            color: accent,
                          ),
                          _FocusBadge(
                            label:
                                '${'due_date'.tr}: ${_formatTaskDate(context, task.dueDate)}',
                            color: accentAction,
                            backgroundColor: dueDateBadgeBackground,
                            borderColor: dueDateBadgeBorder,
                            foregroundColor: dueDateBadgeForeground,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'pick_task_focus_body'.tr,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.74 : 0.66,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back<void>();
                    _showMiniFocusMode(context, task);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryActionBackground,
                    foregroundColor: primaryActionForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    'pick_task_focus_primary'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    Get.back<void>();
                    final anotherTask = await controller.pickTaskForMe();
                    if (anotherTask != null && context.mounted) {
                      await _showPickTaskFocusCard(context, anotherTask);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: Text(
                    'pick_task_focus_secondary'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final currentTheme = ThemeService.currentTheme.value;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final colorScheme = theme.colorScheme;
    final homeFabColor = currentTheme == AppThemePreset.carbonBlue
        ? colorScheme.primary
        : iconPalette.tasks;
    final homeFabIconColor = currentTheme == AppThemePreset.midnightBlack
        ? (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor)
        : currentTheme == AppThemePreset.matteBlack
        ? (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor)
        : Colors.white;
    final pickTaskFabColor = homeFabColor;
    final pickTaskFabIconColor = switch (currentTheme) {
      AppThemePreset.royalIvory => Colors.white,
      AppThemePreset.midnightBlack =>
        (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      AppThemePreset.matteBlack =>
        (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      AppThemePreset.carbonBlue => iconPalette.tasks,
    };
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color cardColor = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final fabGlow = [
      BoxShadow(
        color: switch (currentTheme) {
          AppThemePreset.royalIvory => homeFabColor.withValues(alpha: 0.16),
          AppThemePreset.midnightBlack => homeFabColor.withValues(alpha: 0.24),
          AppThemePreset.matteBlack => homeFabColor.withValues(alpha: 0.14),
          AppThemePreset.carbonBlue => iconPalette.navigation.withValues(
            alpha: 0.12,
          ),
        },
        blurRadius: switch (currentTheme) {
          AppThemePreset.royalIvory => 12,
          AppThemePreset.midnightBlack => 16,
          AppThemePreset.matteBlack => 10,
          AppThemePreset.carbonBlue => 10,
        },
        spreadRadius: switch (currentTheme) {
          AppThemePreset.royalIvory => 0.2,
          AppThemePreset.midnightBlack => 0.35,
          AppThemePreset.matteBlack => 0.18,
          AppThemePreset.carbonBlue => 0.2,
        },
        offset: const Offset(0, 0),
      ),
    ];
    return Scaffold(
      drawer: const AppSideDrawer(),
      appBar: AppBar(
        title: Text('home_title'.tr),
        elevation: 0,
        flexibleSpace: null,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) {
              if (value == 'priority') {
                controller.changeFilter(TaskFilter.priority);
              } else {
                controller.changeFilter(TaskFilter.none);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'none', child: Text('filter_none'.tr)),
              PopupMenuItem(
                value: 'priority',
                child: Text('filter_priority'.tr),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: pageBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Obx(() {
                    if (!controller.dailyRhythmLoaded.value ||
                        !controller.needsDailyRhythmSetup) {
                      return const SizedBox.shrink();
                    }

                    final selectedSleep = Rx<TimeOfDay?>(
                      controller.sleepTime.value,
                    );
                    final selectedWake = Rx<TimeOfDay?>(
                      controller.wakeTime.value,
                    );
                    final bool isRoyalIvory =
                        currentTheme == AppThemePreset.royalIvory;
                    final Color timeButtonForeground = isRoyalIvory
                        ? const Color(0xFF7C5A2F)
                        : colorScheme.onSurface;
                    final Color timeButtonBackground = isRoyalIvory
                        ? Color.alphaBlend(
                            colorScheme.primary.withValues(alpha: 0.035),
                            cardColor,
                          )
                        : theme.inputDecorationTheme.fillColor ?? cardColor;
                    final Color timeButtonBorder = isRoyalIvory
                        ? Color.alphaBlend(
                            colorScheme.primary.withValues(alpha: 0.10),
                            cardColor,
                          )
                        : borderColor;
                    final Color saveButtonBackground = isRoyalIvory
                        ? const Color(0xFF9C6B38)
                        : isDark
                        ? colorScheme.secondary
                        : colorScheme.primary;
                    final Color saveButtonForeground = isRoyalIvory
                        ? const Color(0xFFFFFBF5)
                        : theme.semanticPalette.onAccent;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'daily_rhythm_title'.tr,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'daily_rhythm_body'.tr,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: subtitleColor),
                          ),
                          const SizedBox(height: 14),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickSleepOrWakeTime(
                                      context,
                                      isSleep: false,
                                      target: selectedWake,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: timeButtonForeground,
                                      backgroundColor: timeButtonBackground,
                                      side: BorderSide(color: timeButtonBorder),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.wb_sunny_outlined,
                                      color: timeButtonForeground,
                                    ),
                                    label: Text(
                                      controller.formatTimeLabel(
                                        selectedWake.value,
                                      ),
                                      style: TextStyle(
                                        color: timeButtonForeground,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _pickSleepOrWakeTime(
                                      context,
                                      isSleep: true,
                                      target: selectedSleep,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: timeButtonForeground,
                                      backgroundColor: timeButtonBackground,
                                      side: BorderSide(color: timeButtonBorder),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.nightlight_round,
                                      color: timeButtonForeground,
                                    ),
                                    label: Text(
                                      controller.formatTimeLabel(
                                        selectedSleep.value,
                                      ),
                                      style: TextStyle(
                                        color: timeButtonForeground,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final sleep = selectedSleep.value;
                                final wake = selectedWake.value;
                                if (sleep == null || wake == null) {
                                  AppSnackbar.showError(
                                    'home_title'.tr,
                                    'daily_rhythm_error'.tr,
                                  );
                                  return;
                                }

                                await controller.saveDailyRhythm(
                                  sleep: sleep,
                                  wake: wake,
                                );
                                AppSnackbar.showSuccess(
                                  'home_title'.tr,
                                  'daily_rhythm_saved'.tr,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: saveButtonBackground,
                                foregroundColor: saveButtonForeground,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'daily_rhythm_save'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          104 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final taskTone = theme.taskPalette.toneForPriority(
                            task.priority,
                          );
                          final Color cardBg = taskTone.background;
                          final Color cardBorder = taskTone.border;
                          final Color accent = taskTone.accent;
                          final Color editDividerColor = switch (currentTheme) {
                            AppThemePreset.royalIvory => const Color(
                              0xFFB07A3E,
                            ),
                            AppThemePreset.midnightBlack => accent.withValues(
                              alpha: 0.52,
                            ),
                            AppThemePreset.matteBlack => accent.withValues(
                              alpha: 0.44,
                            ),
                            AppThemePreset.carbonBlue => accent.withValues(
                              alpha: 0.46,
                            ),
                          };
                          final Color titleColor = theme.colorScheme.onSurface;
                          final Color subtitleColor = theme
                              .colorScheme
                              .onSurface
                              .withValues(alpha: isDark ? 0.72 : 0.62);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Dismissible(
                              key: ObjectKey(task),
                              direction: DismissDirection.endToStart,
                              movementDuration: const Duration(
                                milliseconds: 180,
                              ),
                              background: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        theme.semanticPalette.danger,
                                        theme.semanticPalette.snackbarDanger,
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 18),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: theme.semanticPalette.onDanger,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sil',
                                        style: TextStyle(
                                          color: theme.semanticPalette.onDanger,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              confirmDismiss: (_) async {
                                await controller.removeTask(task);
                                return false;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cardBorder,
                                    width: 1.35,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 2,
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    minVerticalPadding: 2,
                                    visualDensity: const VisualDensity(
                                      horizontal: 0,
                                      vertical: -2,
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 0,
                                      right: 12,
                                    ),
                                    leading: Checkbox(
                                      value: task.isCompleted,
                                      activeColor: accent,
                                      checkColor:
                                          theme.semanticPalette.onAccent,
                                      side: isDark
                                          ? null
                                          : BorderSide(
                                              color: accent.withValues(
                                                alpha: 0.30,
                                              ),
                                              width: 1.2,
                                            ),
                                      onChanged: (_) =>
                                          controller.toggleComplete(task),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: isDark ? 0.15 : 0.10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            controller.getPriorityLabel(
                                              task.priority,
                                            ),
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: titleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${'due_date'.tr}: ${_formatTaskDate(context, task.dueDate)}',
                                        style: TextStyle(color: subtitleColor),
                                      ),
                                    ),
                                    trailing: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => controller.editTask(task),
                                      child: SizedBox(
                                        width: 58,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 2,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: editDividerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .semanticPalette
                                                    .transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: isDark
                                                    ? theme
                                                          .colorScheme
                                                          .onSurface
                                                    : currentTheme ==
                                                          AppThemePreset
                                                              .royalIvory
                                                    ? const Color(0xFF8A5A12)
                                                    : accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              Obx(() {
                if (!controller.showPickTaskIntro.value) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  right: 16,
                  bottom: 94 + MediaQuery.of(context).padding.bottom,
                  child: _PickTaskIntroCard(
                    isDark: isDark,
                    onDismiss: controller.dismissPickTaskIntro,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: fabGlow,
              ),
              child: FloatingActionButton.small(
                heroTag: 'home_add_task_fab',
                onPressed: () => Get.toNamed(
                  AppRoutes.taskDetail,
                )?.then((_) => controller.loadTasks()),
                backgroundColor: homeFabColor,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tooltip: 'add_task'.tr,
                child: Icon(
                  Icons.add_rounded,
                  color: homeFabIconColor,
                  size: 20,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: fabGlow,
              ),
              child: FloatingActionButton.small(
                heroTag: 'home_pick_task_fab',
                onPressed: () async {
                  await controller.dismissPickTaskIntro();
                  final selectedTask = await controller.pickTaskForMe();
                  if (selectedTask != null && context.mounted) {
                    await _showPickTaskFocusCard(context, selectedTask);
                  }
                },
                backgroundColor: pickTaskFabColor,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tooltip: 'pick_task_button'.tr,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: pickTaskFabIconColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusBadge extends StatelessWidget {
  const _FocusBadge({
    required this.label,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor ?? color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PickTaskIntroCard extends StatelessWidget {
  const _PickTaskIntroCard({required this.isDark, required this.onDismiss});

  final bool isDark;
  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeService.currentTheme.value;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final accentColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final pickTaskFabIconColor = switch (currentTheme) {
      AppThemePreset.royalIvory => theme.semanticPalette.onAccent,
      AppThemePreset.midnightBlack =>
        (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      AppThemePreset.matteBlack =>
        (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      AppThemePreset.carbonBlue => iconPalette.tasks,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Material(
        color: theme.semanticPalette.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.surfaceBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isDark ? 0.14 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: pickTaskFabIconColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'pick_task_intro_title'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onDismiss,
                    splashRadius: 18,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.72 : 0.60,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'pick_task_intro_body'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.35,
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: isDark ? 0.72 : 0.64,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'pick_task_intro_action'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
