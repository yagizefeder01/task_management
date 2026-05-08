import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/theme_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_themes.dart';
import '../../core/widgets/app_side_drawer.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const List<({String code, String label, String flag})>
  _languageOptions = [
    (code: 'tr', label: 'Türkçe', flag: '🇹🇷'),
    (code: 'en', label: 'English', flag: '🇬🇧'),
    (code: 'zh', label: '中文', flag: '🇨🇳'),
    (code: 'hi', label: 'हिंदी', flag: '🇮🇳'),
    (code: 'es', label: 'Español', flag: '🇪🇸'),
    (code: 'pt', label: 'Português', flag: '🇵🇹'),
    (code: 'fr', label: 'Français', flag: '🇫🇷'),
    (code: 'ar', label: 'العربية', flag: '🇸🇦'),
    (code: 'ru', label: 'Русский', flag: '🇷🇺'),
    (code: 'de', label: 'Deutsch', flag: '🇩🇪'),
  ];

  static const List<({AppThemePreset theme, IconData? icon, bool useBearIcon})>
  _themeOptions = [
    (
      theme: AppThemePreset.royalIvory,
      icon: Icons.light_mode_rounded,
      useBearIcon: false,
    ),
    (
      theme: AppThemePreset.midnightBlack,
      icon: Icons.nightlight_round,
      useBearIcon: false,
    ),
    (
      theme: AppThemePreset.matteBlack,
      icon: Icons.circle_rounded,
      useBearIcon: false,
    ),
    (theme: AppThemePreset.carbonBlue, icon: null, useBearIcon: true),
  ];

  Future<void> _showLanguageSheet(BuildContext context, bool isDark) async {
    final String selectedCode = controller.localeCode.value;
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.7;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetBackground = theme.cardColor;
    final textColor = colorScheme.onSurface;
    final activeColor = colorScheme.secondary;
    final inactiveColor = textColor.withValues(alpha: isDark ? 0.62 : 0.56);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings_language'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: _languageOptions
                          .map(
                            (option) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              leading: Icon(
                                option.code == selectedCode
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: option.code == selectedCode
                                    ? activeColor
                                    : inactiveColor,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    option.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: textColor,
                                            fontWeight:
                                                option.code == selectedCode
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                controller.changeLocale(option.code);
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
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
    final currentTheme = ThemeService.currentTheme.value;
    final iconPalette = AppThemes.iconPaletteFor(currentTheme);
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color surfaceColor = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color textColor = colorScheme.onSurface;
    final Color subtitleColor = textColor.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final Color iconColor = iconPalette.settings;
    final Color sleepButtonBackground =
        currentTheme == AppThemePreset.carbonBlue
        ? iconColor
        : colorScheme.primary;
    final Color sleepButtonForeground =
        currentTheme == AppThemePreset.carbonBlue
        ? pageBackground
        : Colors.white;
    final Color fieldFillColor =
        theme.inputDecorationTheme.fillColor ?? surfaceColor;
    final Color shadowColor =
        theme.cardTheme.shadowColor ?? Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      drawer: const AppSideDrawer(),
      appBar: AppBar(title: Text('settings_title'.tr), elevation: 0),
      body: Container(
        color: pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: isDark
                        ? Border.all(color: borderColor, width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language_rounded, color: iconColor),
                          const SizedBox(width: 8),
                          Text(
                            'settings_language'.tr,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final selectedLanguage = _languageOptions.firstWhere(
                          (option) =>
                              option.code == controller.localeCode.value,
                          orElse: () => _languageOptions.first,
                        );

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _showLanguageSheet(context, isDark),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'settings_language'.tr,
                                filled: true,
                                fillColor: fieldFillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: colorScheme.secondary,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    selectedLanguage.flag,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedLanguage.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: textColor),
                                    ),
                                  ),
                                  Icon(
                                    Icons.expand_more_rounded,
                                    color: iconColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: isDark
                        ? Border.all(color: borderColor, width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bedtime_rounded, color: iconColor),
                          const SizedBox(width: 8),
                          Text(
                            'settings_sleep_title'.tr,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'settings_sleep_body'.tr,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to<void>(
                              () => _SleepScheduleSettingsPage(
                                controller: controller,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sleepButtonBackground,
                            foregroundColor: sleepButtonForeground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'settings_sleep_open'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: sleepButtonForeground,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: isDark
                        ? Border.all(color: borderColor, width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_rounded, color: iconColor),
                          const SizedBox(width: 8),
                          Text(
                            'settings_theme'.tr,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final selectedTheme = controller.selectedTheme.value;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _themeOptions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.75,
                              ),
                          itemBuilder: (context, index) {
                            final option = _themeOptions[index];
                            final previewPalette = AppThemes.previewPaletteFor(
                              option.theme,
                            );

                            return _ThemeOptionCard(
                              label: switch (option.theme) {
                                AppThemePreset.royalIvory =>
                                  'theme_royal_ivory'.tr,
                                AppThemePreset.midnightBlack =>
                                  'theme_midnight_black'.tr,
                                AppThemePreset.matteBlack =>
                                  'theme_matte_black'.tr,
                                AppThemePreset.carbonBlue =>
                                  'theme_carbon_blue'.tr,
                              },
                              icon: option.icon,
                              useBearIcon: option.useBearIcon,
                              primary: previewPalette.primary,
                              secondary: previewPalette.accent,
                              selected: selectedTheme == option.theme,
                              onTap: () => controller.changeTheme(option.theme),
                              isDarkPage: isDark,
                            );
                          },
                        );
                      }),
                    ],
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

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.label,
    this.icon,
    required this.useBearIcon,
    required this.primary,
    required this.secondary,
    required this.selected,
    required this.onTap,
    required this.isDarkPage,
  });

  final String label;
  final IconData? icon;
  final bool useBearIcon;
  final Color primary;
  final Color secondary;
  final bool selected;
  final VoidCallback onTap;
  final bool isDarkPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconForegroundColor = primary.computeLuminance() > 0.72
        ? secondary
        : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? primary.withValues(alpha: isDarkPage ? 0.28 : 0.12)
                : theme.cardColor,
            border: Border.all(
              color: selected
                  ? secondary
                  : theme.colorScheme.secondary.withValues(
                      alpha: isDarkPage ? 0.28 : 0.12,
                    ),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    theme.cardTheme.shadowColor ??
                    Colors.black.withValues(alpha: isDarkPage ? 0.16 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: secondary.withValues(alpha: 0.92),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: useBearIcon
                          ? const _PolarBearIcon()
                          : Icon(icon, color: iconForegroundColor, size: 18),
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: secondary,
                      size: 18,
                    ),
                ],
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: secondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolarBearIcon extends StatelessWidget {
  const _PolarBearIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 1, top: 1, child: _buildEar()),
          Positioned(right: 1, top: 1, child: _buildEar()),
          Container(
            width: 16,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(top: 5, left: 4, child: _buildEye()),
                Positioned(top: 5, right: 4, child: _buildEye()),
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 6,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEar() {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFDBEAFE).withValues(alpha: 0.55),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 2,
      height: 2,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SleepScheduleSettingsPage extends StatelessWidget {
  const _SleepScheduleSettingsPage({required this.controller});

  final SettingsController controller;

  Future<void> _pickTime(
    BuildContext context, {
    required Rx<TimeOfDay?> target,
    required TimeOfDay fallback,
    required String titleKey,
  }) async {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final initialTime = target.value ?? fallback;
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        final Color surfaceColor = theme.cardColor;
        final Color textColor = colorScheme.onSurface;
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(
                        alpha: isDark ? 0.32 : 0.22,
                      ),
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
                        titleKey.tr,
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
                              backgroundColor: colorScheme.primary,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final currentTheme = ThemeService.currentTheme.value;
    final Color pageBackground = theme.scaffoldBackgroundColor;
    final Color surfaceColor = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color timeButtonForeground = colorScheme.onSurface;
    final Color timeButtonBackground =
        theme.inputDecorationTheme.fillColor ?? surfaceColor;
    final Color timeButtonBorder = borderColor;
    final Color saveButtonBackground = currentTheme == AppThemePreset.carbonBlue
        ? AppThemes.iconPaletteFor(currentTheme).settings
        : colorScheme.primary;
    final Color saveButtonForeground = currentTheme == AppThemePreset.carbonBlue
        ? pageBackground
        : Colors.white;
    final Color subtitleColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.78 : 0.68,
    );
    final Color shadowColor =
        theme.cardTheme.shadowColor ?? Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      appBar: AppBar(title: Text('settings_sleep_title'.tr), elevation: 0),
      body: Container(
        color: pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: isDark
                    ? Border.all(color: borderColor, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings_sleep_body'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickTime(
                              context,
                              target: controller.wakeTime,
                              fallback: const TimeOfDay(hour: 7, minute: 0),
                              titleKey: 'settings_wake_time_picker_title',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: timeButtonForeground,
                              backgroundColor: timeButtonBackground,
                              side: BorderSide(color: timeButtonBorder),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
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
                                controller.wakeTime.value,
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
                            onPressed: () => _pickTime(
                              context,
                              target: controller.sleepTime,
                              fallback: const TimeOfDay(hour: 23, minute: 0),
                              titleKey: 'settings_sleep_time_picker_title',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: timeButtonForeground,
                              backgroundColor: timeButtonBackground,
                              side: BorderSide(color: timeButtonBorder),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
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
                                controller.sleepTime.value,
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
                        await controller.saveDailyRhythm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saveButtonBackground,
                        foregroundColor: saveButtonForeground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'settings_sleep_save'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
