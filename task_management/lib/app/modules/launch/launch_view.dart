import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_themes.dart';
import '../../data/services/theme_service.dart';
import 'launch_controller.dart';

class LaunchView extends GetView<LaunchController> {
  const LaunchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final iconPalette = AppThemes.iconPaletteFor(
      ThemeService.currentTheme.value,
    );
    final subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.scaffoldBackgroundColor, theme.cardColor],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.scaffoldBackgroundColor, theme.cardColor],
                ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colorScheme.secondary.withValues(
                                alpha: isDark ? 0.28 : 0.12,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 18,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'local_storage_info'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Spacer(),
                        Text(
                          'launch_title'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'launch_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: subtitleColor),
                        ),
                        const SizedBox(height: 28),
                        _LaunchCard(
                          isDark: isDark,
                          icon: Icons.checklist_rounded,
                          title: 'home_title'.tr,
                          subtitle: 'launch_tasks_desc'.tr,
                          accent: iconPalette.tasks,
                          onTap: controller.goToTasks,
                        ),
                        const SizedBox(height: 14),
                        _LaunchCard(
                          isDark: isDark,
                          icon: Icons.menu_book_rounded,
                          title: 'bookshelf_title'.tr,
                          subtitle: 'launch_books_desc'.tr,
                          accent: iconPalette.tasks,
                          onTap: controller.goToBooks,
                        ),
                        const SizedBox(height: 14),
                        _LaunchCard(
                          isDark: isDark,
                          icon: Icons.shopping_bag_rounded,
                          title: 'shopping_list'.tr,
                          subtitle: 'launch_shopping_desc'.tr,
                          accent: iconPalette.shopping,
                          onTap: controller.goToShoppingList,
                        ),
                        const SizedBox(height: 14),
                        _LaunchCard(
                          isDark: isDark,
                          icon: Icons.autorenew_rounded,
                          title: 'periodic_tracking'.tr,
                          subtitle: 'launch_periodic_desc'.tr,
                          accent: iconPalette.periodic,
                          onTap: controller.goToPeriodicTracking,
                        ),
                        const SizedBox(height: 14),
                        _LaunchCard(
                          isDark: isDark,
                          icon: Icons.settings_rounded,
                          title: 'settings_title'.tr,
                          subtitle: 'launch_settings_desc'.tr,
                          accent: iconPalette.settings,
                          onTap: controller.goToSettings,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
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
                color:
                    Theme.of(context).cardTheme.shadowColor ??
                    Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
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
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: isDark ? 0.78 : 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
