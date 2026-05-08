import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_side_drawer.dart';
import '../../data/services/theme_service.dart';
import 'shopping_list_controller.dart';

class ShoppingListView extends GetView<ShoppingListController> {
  const ShoppingListView({super.key});

  static const TextStyle _dialogDangerStyle = TextStyle(
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _bottomActionTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  double _estimateListCardHeight(
    Map<String, dynamic> list,
    List<Map<String, dynamic>> items,
  ) {
    final title = list['title'] as String? ?? '';
    final previewCount = items.length > 4 ? 4 : items.length;
    final extraTitleLines = (title.length / 18).floor();

    return 132 + (previewCount * 52) + (extraTitleLines * 20);
  }

  List<List<({Map<String, dynamic> list, List<Map<String, dynamic>> items})>>
  _buildBalancedColumns() {
    final leftColumn =
        <({Map<String, dynamic> list, List<Map<String, dynamic>> items})>[];
    final rightColumn =
        <({Map<String, dynamic> list, List<Map<String, dynamic>> items})>[];
    double leftHeight = 0;
    double rightHeight = 0;

    for (final list in controller.lists) {
      final items = List<Map<String, dynamic>>.from(
        (list['items'] as List<dynamic>? ?? const []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      final estimate = _estimateListCardHeight(list, items);

      if (leftHeight <= rightHeight) {
        leftColumn.add((list: list, items: items));
        leftHeight += estimate;
      } else {
        rightColumn.add((list: list, items: items));
        rightHeight += estimate;
      }
    }

    return [leftColumn, rightColumn];
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final semantics = theme.semanticPalette;

    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('shopping_clear_all_title'.tr),
        content: Text('shopping_clear_all_body'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: semantics.contrastForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back<void>();
              await controller.clearAllItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: semantics.danger,
              foregroundColor: semantics.onDanger,
            ),
            child: Text('shopping_clear_all'.tr, style: _dialogDangerStyle),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCheckedDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final semantics = theme.semanticPalette;
    final iconPalette = AppThemes.iconPaletteFor(
      ThemeService.currentTheme.value,
    );

    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('shopping_clear_checked_title'.tr),
        content: Text('shopping_clear_checked_body'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: semantics.contrastForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back<void>();
              await controller.clearCompletedItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconPalette.shopping,
              foregroundColor: semantics.onAccent,
            ),
            child: Text('shopping_clear_checked'.tr, style: _dialogDangerStyle),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemSheet(BuildContext context) async {
    if (controller.selectedList == null) {
      await _showAddListSheet(context);
      return;
    }

    final textController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).semanticPalette.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final semantics = theme.semanticPalette;
        final iconPalette = AppThemes.iconPaletteFor(
          ThemeService.currentTheme.value,
        );
        final accent = iconPalette.shopping;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.surfaceBorderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'shopping_add_item'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  autofocus: true,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    hintText: 'shopping_item_hint'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onSubmitted: (_) async {
                    final saved = await controller.addItem(textController.text);
                    if (saved && context.mounted) Get.back();
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final saved = await controller.addItem(textController.text);
                    if (saved && context.mounted) Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: semantics.onAccent,
                  ),
                  child: Text('shopping_add_item'.tr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddListSheet(BuildContext context) async {
    final textController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        final semantics = theme.semanticPalette;
        final iconPalette = AppThemes.iconPaletteFor(
          ThemeService.currentTheme.value,
        );
        final accent = iconPalette.shopping;

        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.surfaceBorderColor),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.playlist_add_rounded, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'shopping_add_list'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'shopping_list_name_hint'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  hintText: 'shopping_list_name_hint'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onSubmitted: (_) async {
                  final listTitle = textController.text.trim();
                  final saved = await controller.addList(
                    listTitle,
                    showSuccessSnackbar: false,
                  );
                  if (saved && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final listTitle = textController.text.trim();
                final saved = await controller.addList(
                  listTitle,
                  showSuccessSnackbar: false,
                );
                if (saved && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: semantics.onAccent,
              ),
              icon: const Icon(Icons.playlist_add_rounded),
              label: Text('shopping_add_list'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteListDialog(
    BuildContext context,
    Map<String, dynamic> list,
  ) async {
    final theme = Theme.of(context);
    final semantics = theme.semanticPalette;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('shopping_delete_list_title'.tr),
        content: Text('${'shopping_delete_list_body'.tr} ${list['title']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: semantics.contrastForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.removeList(list);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: semantics.danger,
              foregroundColor: semantics.onDanger,
            ),
            child: Text('delete'.tr, style: _dialogDangerStyle),
          ),
        ],
      ),
    );
  }

  Future<void> _showListDetailsSheet(
    BuildContext parentContext,
    Map<String, dynamic> list,
  ) async {
    controller.selectList(list['key']);
    final textController = TextEditingController();

    await showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;
        final currentTheme = ThemeService.currentTheme.value;
        final bool isCarbonBlue = currentTheme == AppThemePreset.carbonBlue;
        final colorScheme = theme.colorScheme;
        final iconPalette = AppThemes.iconPaletteFor(currentTheme);
        final accent = iconPalette.shopping;
        final borderColor = colorScheme.secondary.withValues(
          alpha: isDark ? 0.28 : 0.12,
        );
        final subtitleColor = colorScheme.onSurface.withValues(
          alpha: isDark ? 0.78 : 0.68,
        );
        final detailItemBackground = isCarbonBlue
            ? accent
            : accent.withValues(alpha: isDark ? 0.12 : 0.06);
        final detailItemBorder = isCarbonBlue
            ? accent
            : accent.withValues(alpha: isDark ? 0.30 : 0.16);
        final detailItemForeground = isCarbonBlue
            ? (theme.appBarTheme.backgroundColor ??
                  theme.scaffoldBackgroundColor)
            : colorScheme.onSurface;
        final detailItemMuted = isCarbonBlue
            ? detailItemForeground.withValues(alpha: 0.72)
            : subtitleColor;
        final detailCheckboxShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: WidgetStateBorderSide.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);

            if (isCarbonBlue) {
              return BorderSide(
                color: detailItemForeground,
                width: isSelected ? 2 : 1.8,
              );
            }

            return BorderSide(
              color: isSelected
                  ? accent
                  : accent.withValues(alpha: isDark ? 0.72 : 0.48),
              width: 1.8,
            );
          }),
        );
        final mediaQuery = MediaQuery.of(context);
        final keyboardInset = mediaQuery.viewInsets.bottom;
        final availableHeight = mediaQuery.size.height - keyboardInset;
        final sheetHeight = availableHeight * 0.88;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: sheetHeight,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: borderColor),
                ),
                child: SafeArea(
                  top: false,
                  child: Obx(() {
                    final selectedList = controller.selectedList;
                    final items = controller.currentItems;

                    if (selectedList == null) {
                      return const SizedBox.shrink();
                    }

                    final completedCount = items
                        .where((item) => item['completed'] == true)
                        .length;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 42,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: borderColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedList['title'] as String,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${items.length} ${'shopping_total_items'.tr.toLowerCase()}  •  $completedCount ${'shopping_completed_count'.tr.toLowerCase()}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: subtitleColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Get.back<void>(),
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: textController,
                                    textInputAction: TextInputAction.go,
                                    decoration: InputDecoration(
                                      hintText: 'shopping_item_hint'.tr,
                                      filled: true,
                                      fillColor:
                                          theme.inputDecorationTheme.fillColor,
                                      prefixIcon: Icon(
                                        Icons.add_task_rounded,
                                        color: accent,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (_) async {
                                      final saved = await controller.addItem(
                                        textController.text,
                                      );
                                      if (saved) {
                                        textController.clear();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: items.isEmpty
                                              ? null
                                              : () => _showClearAllDialog(
                                                  context,
                                                ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accent,
                                            side: BorderSide(
                                              color: accent.withValues(
                                                alpha: isDark ? 0.78 : 0.38,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.delete_sweep_rounded,
                                            size: 18,
                                          ),
                                          label: Text(
                                            'shopping_clear_all'.tr,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: completedCount == 0
                                              ? null
                                              : () => _showClearCheckedDialog(
                                                  context,
                                                ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: accent,
                                            side: BorderSide(
                                              color: accent.withValues(
                                                alpha: isDark ? 0.78 : 0.38,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.done_all_rounded,
                                            size: 18,
                                          ),
                                          label: Text(
                                            'shopping_clear_checked'.tr,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: constraints.maxHeight * 0.45,
                                      child: items.isEmpty
                                          ? Center(
                                              child: Text(
                                                'shopping_items_empty_body'.tr,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF94A3B8,
                                                            )
                                                          : const Color(
                                                              0xFF6B7280,
                                                            ),
                                                    ),
                                              ),
                                            )
                                          : ListView.separated(
                                              shrinkWrap: true,
                                              itemCount: items.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(height: 8),
                                              itemBuilder: (context, index) {
                                                final item = items[index];

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: detailItemBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    border: Border.all(
                                                      color: detailItemBorder,
                                                    ),
                                                  ),
                                                  child: CheckboxListTile(
                                                    value:
                                                        item['completed'] ==
                                                        true,
                                                    onChanged: (_) => controller
                                                        .toggleItem(item),
                                                    checkboxShape:
                                                        detailCheckboxShape,
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    checkColor:
                                                        detailItemForeground,
                                                    fillColor:
                                                        WidgetStateProperty.resolveWith(
                                                          (states) {
                                                            if (states.contains(
                                                              WidgetState
                                                                  .selected,
                                                            )) {
                                                              return accent;
                                                            }

                                                            return Colors
                                                                .transparent;
                                                          },
                                                        ),
                                                    activeColor: accent,
                                                    title: Text(
                                                      item['title'] as String,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                item['completed'] ==
                                                                    true
                                                                ? detailItemMuted
                                                                : detailItemForeground,
                                                            decoration:
                                                                item['completed'] ==
                                                                    true
                                                                ? TextDecoration
                                                                      .lineThrough
                                                                : null,
                                                          ),
                                                    ),
                                                    secondary: IconButton(
                                                      onPressed: () =>
                                                          controller.removeItem(
                                                            item,
                                                          ),
                                                      icon: Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: isCarbonBlue
                                                            ? detailItemForeground
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
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
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final iconPalette = AppThemes.iconPaletteFor(
      ThemeService.currentTheme.value,
    );
    final Color surfaceColor = theme.cardColor;
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final Color accent = iconPalette.shopping;

    return Scaffold(
      drawer: const AppSideDrawer(),
      appBar: AppBar(title: Text('shopping_list'.tr), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListSheet(context),
        backgroundColor: accent,
        child: const Icon(Icons.playlist_add_rounded, color: Colors.white),
      ),
      body: Container(
        color: pageBackground,
        child: SafeArea(
          child: Obx(() {
            final listColumns = _buildBalancedColumns();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.cardTheme.shadowColor ??
                            Colors.black.withValues(
                              alpha: isDark ? 0.15 : 0.05,
                            ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.shopping_basket_rounded,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'shopping_list'.tr,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'shopping_lists_subtitle'.tr,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: subtitleColor,
                                  ),
                            ),
                          ],
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
                else if (controller.lists.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 42,
                          color: accent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'shopping_list_empty_title'.tr,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'shopping_list_empty_body'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: subtitleColor),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => _showAddListSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.playlist_add_rounded),
                          label: Text('shopping_list_empty_action'.tr),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: listColumns[0]
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ShoppingListCard(
                                    list: entry.list,
                                    items: entry.items,
                                    isDark: isDark,
                                    onTap: () => _showListDetailsSheet(
                                      context,
                                      entry.list,
                                    ),
                                    onDelete: () => _showDeleteListDialog(
                                      context,
                                      entry.list,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: listColumns[1]
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ShoppingListCard(
                                    list: entry.list,
                                    items: entry.items,
                                    isDark: isDark,
                                    onTap: () => _showListDetailsSheet(
                                      context,
                                      entry.list,
                                    ),
                                    onDelete: () => _showDeleteListDialog(
                                      context,
                                      entry.list,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ShoppingListCard extends StatelessWidget {
  const _ShoppingListCard({
    required this.list,
    required this.items,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> list;
  final List<Map<String, dynamic>> items;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ThemeService.currentTheme.value;
    final bool isCarbonBlue = currentTheme == AppThemePreset.carbonBlue;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final accent = iconPalette.shopping;
    final subtitleColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final previewItemBackground = isCarbonBlue
        ? accent
        : accent.withValues(alpha: isDark ? 0.12 : 0.06);
    final previewItemBorder = isCarbonBlue
        ? accent
        : accent.withValues(alpha: isDark ? 0.30 : 0.16);
    final previewItemForeground = isCarbonBlue
        ? theme.scaffoldBackgroundColor
        : theme.colorScheme.onSurface;
    final pendingCount = items
        .where((item) => item['completed'] != true)
        .length;
    final previewItems = items.take(4).toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: isDark ? 0.28 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        list['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      color: const Color(0xFFB91C1C),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$pendingCount ${'shopping_pending'.tr.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (previewItems.isEmpty)
                  Text(
                    'shopping_items_empty_title'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                  )
                else
                  ...previewItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: previewItemBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: previewItemBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                item['completed'] == true
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: item['completed'] == true
                                    ? (isCarbonBlue
                                          ? previewItemForeground
                                          : accent)
                                    : (isCarbonBlue
                                          ? previewItemForeground
                                          : subtitleColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: item['completed'] == true
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item['completed'] == true
                                      ? (isCarbonBlue
                                            ? previewItemForeground.withValues(
                                                alpha: 0.72,
                                              )
                                            : subtitleColor)
                                      : previewItemForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (items.length > previewItems.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${items.length - previewItems.length} ${'shopping_total_items'.tr.toLowerCase()}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: subtitleColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
