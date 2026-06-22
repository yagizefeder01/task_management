import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../data/services/theme_service.dart';
import 'task_detail_controller.dart';

class TaskDetailView extends GetView<TaskDetailController> {
  const TaskDetailView({super.key});

  Color _priorityColor(bool isDark, int value) {
    return Get.theme.taskPalette.toneForPriority(value).accent;
  }

  String _dateText(DateTime value) {
    return value.toLocal().toString().split(' ').first;
  }

  bool _isQuickDateSelected(DateTime? selectedDate, int offset) {
    if (selectedDate == null) {
      return false;
    }

    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + offset);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return selected == target;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final currentTheme = ThemeService.currentTheme.value;
    final bool isRoyalIvory = currentTheme == AppThemePreset.royalIvory;
    final bool isGoldenNight = currentTheme == AppThemePreset.midnightBlack;
    final colorScheme = theme.colorScheme;
    final accentPalette = AppThemes.iconPaletteFor(currentTheme);
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color cardColor = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final Color saveButtonColor = isGoldenNight
        ? accentPalette.tasks
        : isRoyalIvory
        ? const Color(0xFF9C6B38)
        : theme.semanticPalette.success;
    final Color saveButtonForeground = isGoldenNight
        ? (theme.appBarTheme.backgroundColor ?? pageBackground)
        : isRoyalIvory
        ? const Color(0xFFFFFBF5)
        : theme.semanticPalette.onAccent;
    final Color titleFieldFillColor = theme.semanticPalette.softSurface;
    final Color titleFieldHintColor = isGoldenNight
        ? accentPalette.tasks.withValues(alpha: 0.72)
        : subtitleColor;
    final Color? titleFieldIdleIconColor = isGoldenNight
        ? accentPalette.tasks
        : isRoyalIvory
        ? const Color(0xFF8A5A12)
        : null;
    final Color titleCheckForeground = isGoldenNight
        ? (theme.appBarTheme.backgroundColor ?? pageBackground)
        : isRoyalIvory
        ? const Color(0xFF9C6B38)
        : theme.semanticPalette.success;
    final Color headerIconBackground = switch (currentTheme) {
      AppThemePreset.royalIvory => const Color(0xFFF1E3CF),
      AppThemePreset.midnightBlack => accentPalette.tasks,
      AppThemePreset.matteBlack => accentPalette.tasks.withValues(alpha: 0.18),
      AppThemePreset.carbonBlue => accentPalette.tasks,
    };
    final Color headerIconForeground = switch (currentTheme) {
      AppThemePreset.royalIvory => const Color(0xFF8A5A12),
      AppThemePreset.midnightBlack =>
        (theme.appBarTheme.backgroundColor ?? pageBackground),
      AppThemePreset.matteBlack => accentPalette.tasks,
      AppThemePreset.carbonBlue =>
        (theme.appBarTheme.backgroundColor ?? pageBackground),
    };
    final Color dueDateIconBackground = switch (currentTheme) {
      AppThemePreset.royalIvory => const Color(0xFFF1E3CF),
      AppThemePreset.midnightBlack => accentPalette.tasks,
      AppThemePreset.matteBlack => accentPalette.tasks.withValues(alpha: 0.18),
      AppThemePreset.carbonBlue => accentPalette.tasks,
    };
    final Color dueDateIconForeground = switch (currentTheme) {
      AppThemePreset.royalIvory => const Color(0xFF8A5A12),
      AppThemePreset.midnightBlack =>
        (theme.appBarTheme.backgroundColor ?? pageBackground),
      AppThemePreset.matteBlack => accentPalette.tasks,
      AppThemePreset.carbonBlue =>
        (theme.appBarTheme.backgroundColor ?? pageBackground),
    };
    final Color dueDateActionColor = accentPalette.tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'task_detail'.tr : 'add_task'.tr),
        elevation: 0,
        actions: controller.isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_forever_outlined),
                  color: theme.semanticPalette.danger,
                  onPressed: controller.removeTask,
                ),
              ]
            : [],
      ),
      backgroundColor: pageBackground,
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          keyboardInset > 0 ? keyboardInset + 12 : 16,
        ),
        child: Obx(() {
          final canSave = controller.canSave;
          return SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: canSave
                  ? () {
                      FocusScope.of(context).unfocus();
                      controller.saveTask();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canSave
                    ? saveButtonColor
                    : theme.semanticPalette.softSurface,
                disabledBackgroundColor: theme.semanticPalette.softSurface,
                foregroundColor: saveButtonForeground,
                disabledForegroundColor: isDark
                    ? theme.semanticPalette.mutedForeground
                    : theme.semanticPalette.mutedForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canSave ? Icons.check_circle_rounded : Icons.lock_outline,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      canSave ? 'save'.tr : 'Baslik ve tarih gerekli',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: theme.semanticPalette.overlayShadow.withValues(
                        alpha: isDark ? 0.16 : 0.05,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: headerIconBackground,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        controller.isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_task_rounded,
                        color: headerIconForeground,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isEditing
                                ? 'task_detail'.tr
                                : 'add_task'.tr,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.isEditing
                                ? 'Görevi daha net, daha düzenli hale getir.'
                                : 'Yeni görevi başlık, önem ve başlangıç tarihiyle hızlıca oluştur.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: subtitleColor, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Görev başlığı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kısa ama net bir başlık yaz. Liste görünümünde ilk bunu göreceksin.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => TextField(
                        controller: controller.titleController,
                        maxLines: 2,
                        minLines: 1,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'title_hint'.tr,
                          hintStyle: TextStyle(color: titleFieldHintColor),
                          filled: true,
                          fillColor: titleFieldFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(18),
                          suffixIcon: controller.titleText.value.trim().isEmpty
                              ? Icon(
                                  Icons.edit_outlined,
                                  color: titleFieldIdleIconColor,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: titleCheckForeground,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'priority'.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bu görev bugün ne kadar öne çıksın?',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Column(
                        children: [
                          for (final value in [1, 2, 3]) ...[
                            _PriorityOptionCard(
                              label: switch (value) {
                                1 => 'priority_level_1'.tr,
                                2 => 'priority_level_2'.tr,
                                _ => 'priority_level_3'.tr,
                              },
                              description: switch (value) {
                                1 => 'Rahat tempoda ilerleyebilir.',
                                2 => 'Bugün görünür olsun ve odağa girsin.',
                                _ => 'İlk ele alınması gereken görev.',
                              },
                              color: _priorityColor(isDark, value),
                              selected: controller.priority.value == value,
                              onTap: () => controller.setPriorityValue(value),
                            ),
                            if (value != 3) const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'due_date'.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Göreve ne zaman başladığını belirle. Liste sıralaması ve hissi buna göre daha anlamlı olur.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => controller.selectDueDate(context),
                        child: Ink(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8F1E7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: dueDateIconBackground,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.event_rounded,
                                  color: dueDateIconForeground,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.dueDate.value == null
                                          ? 'Tarih secilmedi'
                                          : _dateText(
                                              controller.dueDate.value!,
                                            ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.dueDate.value == null
                                          ? 'Kaydetmek icin once bir tarih sec.'
                                          : controller.relativeDateLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: subtitleColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        controller.selectDueDate(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: dueDateActionColor,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      controller.dueDate.value == null
                                          ? 'Sec'
                                          : 'Degistir',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickDateChip(
                              label: 'Bugün',
                              selected: _isQuickDateSelected(
                                controller.dueDate.value,
                                0,
                              ),
                              onTap: () => controller.setDueDateFromNow(0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickDateChip(
                              label: 'Yarın',
                              selected: _isQuickDateSelected(
                                controller.dueDate.value,
                                1,
                              ),
                              onTap: () => controller.setDueDateFromNow(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickDateChip(
                              label: '3 gün sonra',
                              selected: _isQuickDateSelected(
                                controller.dueDate.value,
                                3,
                              ),
                              onTap: () => controller.setDueDateFromNow(3),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _PriorityOptionCard extends StatelessWidget {
  const _PriorityOptionCard({
    required this.label,
    required this.description,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: selected ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final currentTheme = ThemeService.currentTheme.value;
    final bool isRoyalIvory = currentTheme == AppThemePreset.royalIvory;
    final bool isGoldenNight = currentTheme == AppThemePreset.midnightBlack;
    final accent = AppThemes.iconPaletteFor(currentTheme).tasks;
    final foreground = isGoldenNight
        ? (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor)
        : isRoyalIvory
        ? const Color(0xFFFFFBF5)
        : Colors.white;
    final unselectedBackground = isGoldenNight
        ? accent.withValues(alpha: 0.20)
        : isRoyalIvory
        ? const Color(0xFFF7EFE2)
        : isDark
        ? const Color(0xFF1F2937)
        : const Color(0xFFF5EEDF);
    final unselectedBorder = isGoldenNight
        ? accent
        : isRoyalIvory
        ? const Color(0xFFE0CCAE)
        : isDark
        ? const Color(0xFF334155)
        : const Color(0xFFDDC8A3);
    final unselectedForeground = isGoldenNight
        ? accent
        : isRoyalIvory
        ? const Color(0xFF8A5A12)
        : isDark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF85541A);
    final selectedColor = isGoldenNight
        ? accent
        : isRoyalIvory
        ? const Color(0xFF9C6B38)
        : const Color(0xFF16A34A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? selectedColor : unselectedBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? selectedColor : unselectedBorder,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? foreground : unselectedForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
