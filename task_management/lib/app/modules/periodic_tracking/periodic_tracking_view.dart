import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_date_picker_sheet.dart';
import '../../core/widgets/app_side_drawer.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/theme_service.dart';
import 'periodic_tracking_controller.dart';

class PeriodicTrackingView extends GetView<PeriodicTrackingController> {
  const PeriodicTrackingView({super.key});

  String _formatDisplayDate(BuildContext context, DateTime date) {
    final localDate = date.toLocal();
    final shortMonthDay = MaterialLocalizations.of(
      context,
    ).formatShortMonthDay(localDate);
    return '$shortMonthDay ${localDate.year}';
  }

  String _titleHint(String category) {
    switch (category) {
      case 'home':
        return 'periodic_title_hint_home'.tr;
      case 'hobby':
        return 'periodic_title_hint_hobby'.tr;
      default:
        return 'periodic_title_hint_vehicle'.tr;
    }
  }

  String _intervalValueLabel(String unit) {
    switch (unit) {
      case 'weeks':
        return 'periodic_interval_value_weeks'.tr;
      case 'years':
        return 'periodic_interval_value_years'.tr;
      default:
        return 'periodic_interval_value_months'.tr;
    }
  }

  String _intervalValueHint(String unit) {
    switch (unit) {
      case 'weeks':
        return 'periodic_interval_hint_weeks'.tr;
      case 'years':
        return 'periodic_interval_hint_years'.tr;
      default:
        return 'periodic_interval_hint_months'.tr;
    }
  }

  Future<void> _showAddSheet(
    BuildContext context, {
    Map<String, dynamic>? existing,
  }) async {
    final bool isEditing = existing != null;
    final Map<String, dynamic> source = existing ?? const {};
    final titleController = TextEditingController(
      text: isEditing ? (source['title'] as String? ?? '') : '',
    );
    final noteController = TextEditingController(
      text: isEditing ? (source['note'] as String? ?? '') : '',
    );
    final initialIntervalValue = isEditing
        ? (source['intervalValue'] as int? ??
              source['intervalMonths'] as int? ??
              1)
        : 1;
    final intervalController = TextEditingController(
      text: initialIntervalValue.toString(),
    );
    final selectedCategory =
        (isEditing ? (source['category'] as String? ?? 'vehicle') : 'vehicle')
            .obs;
    final selectedIntervalUnit =
        (isEditing ? (source['intervalUnit'] as String? ?? 'months') : 'months')
            .obs;
    final initialDate = isEditing
        ? (DateTime.tryParse(source['lastDoneAt'] as String? ?? '') ??
              DateTime.now())
        : DateTime.now();
    final selectedDate = initialDate.obs;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconPalette = AppThemes.iconPaletteFor(
      ThemeService.currentTheme.value,
    );
    final accent = iconPalette.periodic;
    final sheetSurface = theme.cardColor;
    final sheetText = colorScheme.onSurface;
    final sheetBorder = theme.surfaceBorderColor;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final maxSheetHeight =
            (mediaQuery.size.height - mediaQuery.viewInsets.bottom - 24).clamp(
              320.0,
              mediaQuery.size.height * 0.88,
            );

        Future<void> pickDate() async {
          final pickedDate = await AppDatePickerSheet.show(
            context,
            title: 'periodic_last_done'.tr,
            initialDate: selectedDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            selectedDate.value = pickedDate;
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sheetSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: sheetBorder),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing
                          ? 'periodic_edit_record'.tr
                          : 'periodic_add_record'.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: sheetText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: _titleHint(selectedCategory.value),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: selectedCategory.value,
                        decoration: InputDecoration(
                          labelText: 'periodic_category'.tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'vehicle',
                            child: Text('periodic_category_vehicle'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'home',
                            child: Text('periodic_category_home'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'hobby',
                            child: Text('periodic_category_hobby'.tr),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextField(
                        controller: intervalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _intervalValueLabel(
                            selectedIntervalUnit.value,
                          ),
                          hintText: _intervalValueHint(
                            selectedIntervalUnit.value,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: selectedIntervalUnit.value,
                        decoration: InputDecoration(
                          labelText: 'periodic_interval_unit'.tr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'weeks',
                            child: Text('periodic_interval_unit_weeks'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'months',
                            child: Text('periodic_interval_unit_months'.tr),
                          ),
                          DropdownMenuItem(
                            value: 'years',
                            child: Text('periodic_interval_unit_years'.tr),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            selectedIntervalUnit.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => OutlinedButton.icon(
                        onPressed: pickDate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: sheetText,
                        ),
                        icon: const Icon(Icons.event_rounded),
                        label: Text(
                          '${'periodic_last_done'.tr}: ${_formatDisplayDate(context, selectedDate.value)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'periodic_note_hint'.tr,
                        labelText: 'periodic_note'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        final bool saved;
                        if (isEditing) {
                          saved = await controller.updateItem(
                            key: source['key'],
                            title: titleController.text,
                            category: selectedCategory.value,
                            intervalValue:
                                int.tryParse(intervalController.text.trim()) ??
                                0,
                            intervalUnit: selectedIntervalUnit.value,
                            lastDoneAt: selectedDate.value,
                            note: noteController.text,
                          );
                        } else {
                          saved = await controller.addItem(
                            title: titleController.text,
                            category: selectedCategory.value,
                            intervalValue:
                                int.tryParse(intervalController.text.trim()) ??
                                0,
                            intervalUnit: selectedIntervalUnit.value,
                            lastDoneAt: selectedDate.value,
                            note: noteController.text,
                          );
                        }
                        if (!saved) {
                          return;
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        if (!isEditing) {
                          await AdService.registerPeriodicItemCreated();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        isEditing ? Icons.save_rounded : Icons.add_task_rounded,
                      ),
                      label: Text(
                        isEditing
                            ? 'periodic_save_changes'.tr
                            : 'periodic_add_record'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'home':
        return Icons.home_rounded;
      case 'hobby':
        return Icons.interests_rounded;
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  Color _statusColor(String statusKey) {
    final theme = Get.theme;
    switch (statusKey) {
      case 'periodic_status_late':
        return theme.semanticPalette.danger;
      case 'periodic_status_soon':
        return theme.semanticPalette.warning;
      default:
        return theme.semanticPalette.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final currentTheme = ThemeService.currentTheme.value;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color surfaceColor = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color accent = iconPalette.periodic;
    final Color addIconColor = currentTheme == AppThemePreset.carbonBlue
        ? pageBackground
        : theme.semanticPalette.onAccent;
    final Color subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );

    return Scaffold(
      drawer: const AppSideDrawer(),
      appBar: AppBar(title: Text('periodic_tracking'.tr), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: accent,
        child: Icon(Icons.add_rounded, color: addIconColor),
      ),
      body: Container(
        color: pageBackground,
        child: SafeArea(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: currentTheme == AppThemePreset.carbonBlue
                              ? accent
                              : accent.withValues(alpha: isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.autorenew_rounded,
                          color: currentTheme == AppThemePreset.carbonBlue
                              ? addIconColor
                              : accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'periodic_tracking_subtitle'.tr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.loading.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.autorenew_rounded,
                            size: 30,
                            color: addIconColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'periodic_empty_title'.tr,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'periodic_empty_body'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: subtitleColor),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: addIconColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.add_task_rounded),
                          label: Text(
                            'periodic_empty_action'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...controller.items.map((item) {
                    final statusKey = controller.statusKey(item);
                    final statusColor = _statusColor(statusKey);
                    final lastDone = controller.parseDate(
                      item['lastDoneAt'] as String,
                    );
                    final nextDue = controller.parseDate(
                      item['nextDueAt'] as String,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 8, 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _categoryIcon(item['category'] as String),
                                    color: statusColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          statusKey.tr,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _showAddSheet(context, existing: item),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  color: accent,
                                  tooltip: 'periodic_edit_record'.tr,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.removeItem(item),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                  ),
                                  color: theme.semanticPalette.danger,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${'periodic_last_done'.tr}: ${_formatDisplayDate(context, lastDone)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${'periodic_next_due'.tr}: ${nextDue.toLocal().toString().split(' ').first}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${'periodic_interval'.tr}: ${controller.intervalSummary(item)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  if ((item['note'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item['note'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: subtitleColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () => controller.markDoneToday(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor:
                                      theme.semanticPalette.onAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                ),
                                label: Text('periodic_mark_done'.tr),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
