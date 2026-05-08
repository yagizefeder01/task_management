import 'package:flutter/material.dart';

import '../theme/app_themes.dart';
import '../../data/services/theme_service.dart';

class AppDatePickerSheet {
  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final currentTheme = ThemeService.currentTheme.value;
    DateTime selectedDate = _dateOnly(initialDate);

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final maxSheetHeight = (mediaQuery.size.height * 0.82).clamp(
          420.0,
          720.0,
        );

        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              final Color surfaceColor = isDark
                  ? const Color(0xFF111827)
                  : Colors.white;
              final Color mutedTextColor = isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF475569);
              final Color accentColor = switch (currentTheme) {
                AppThemePreset.royalIvory => const Color(0xFF16A34A),
                AppThemePreset.midnightBlack => AppThemes.iconPaletteFor(
                  currentTheme,
                ).tasks,
                AppThemePreset.matteBlack => AppThemes.iconPaletteFor(
                  currentTheme,
                ).tasks,
                AppThemePreset.carbonBlue => AppThemes.iconPaletteFor(
                  currentTheme,
                ).tasks,
              };
              final Color themeIconColor = AppThemes.iconPaletteFor(
                currentTheme,
              ).tasks;
              final bool useDarkAccentForeground =
                  currentTheme == AppThemePreset.midnightBlack ||
                  currentTheme == AppThemePreset.carbonBlue;
              final Color accentForeground = useDarkAccentForeground
                  ? (theme.appBarTheme.backgroundColor ??
                        theme.scaffoldBackgroundColor)
                  : Colors.white;
              final Color selectedPanelBackground =
                  currentTheme == AppThemePreset.midnightBlack
                  ? accentColor.withValues(alpha: 0.18)
                  : currentTheme == AppThemePreset.carbonBlue
                  ? accentColor.withValues(alpha: 1)
                  : accentColor.withValues(alpha: isDark ? 0.16 : 0.10);
              final Color selectedPanelBorder =
                  currentTheme == AppThemePreset.midnightBlack
                  ? accentColor
                  : currentTheme == AppThemePreset.carbonBlue
                  ? accentColor
                  : accentColor.withValues(alpha: isDark ? 0.75 : 0.35);
              final Color selectedPanelIconBackground = switch (currentTheme) {
                AppThemePreset.royalIvory => accentColor.withValues(
                  alpha: 0.10,
                ),
                AppThemePreset.midnightBlack =>
                  (theme.appBarTheme.backgroundColor ??
                      theme.scaffoldBackgroundColor),
                AppThemePreset.matteBlack => accentColor.withValues(
                  alpha: 0.18,
                ),
                AppThemePreset.carbonBlue => accentColor,
              };
              final Color selectedPanelIconForeground = switch (currentTheme) {
                AppThemePreset.royalIvory => accentColor,
                AppThemePreset.midnightBlack => accentColor,
                AppThemePreset.matteBlack => accentColor,
                AppThemePreset.carbonBlue => accentForeground,
              };
              final Color calendarSurface = switch (currentTheme) {
                AppThemePreset.royalIvory => const Color(0xFFF8FAFC),
                AppThemePreset.midnightBlack => const Color(0xFF09090B),
                AppThemePreset.matteBlack => const Color(0xFF0F172A),
                AppThemePreset.carbonBlue => const Color(0xFF0F172A),
              };
              final Color headerIconBackground = switch (currentTheme) {
                AppThemePreset.royalIvory => accentColor.withValues(
                  alpha: 0.10,
                ),
                AppThemePreset.midnightBlack =>
                  (theme.appBarTheme.backgroundColor ??
                      theme.scaffoldBackgroundColor),
                AppThemePreset.matteBlack => accentColor.withValues(
                  alpha: 0.18,
                ),
                AppThemePreset.carbonBlue => accentColor,
              };
              final Color headerIconForeground = switch (currentTheme) {
                AppThemePreset.royalIvory => accentColor,
                AppThemePreset.midnightBlack => accentColor,
                AppThemePreset.matteBlack => accentColor,
                AppThemePreset.carbonBlue => accentForeground,
              };

              return Container(
                height: maxSheetHeight,
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFD6D3D1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateLabel(selectedDate),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: mutedTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: headerIconBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.event_rounded,
                            color: headerIconForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selectedPanelBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: selectedPanelBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: selectedPanelIconBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_rounded,
                              color: selectedPanelIconForeground,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Secili tarih',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color:
                                            currentTheme ==
                                                AppThemePreset.carbonBlue
                                            ? accentForeground
                                            : accentColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDateLabel(selectedDate),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: calendarSurface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: accentColor,
                              onPrimary: accentForeground,
                              surface: calendarSurface,
                              onSurface: isDark
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF111827),
                            ),
                            datePickerTheme: DatePickerThemeData(
                              backgroundColor: Colors.transparent,
                              dayForegroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return accentForeground;
                                    }
                                    return isDark
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFF111827);
                                  }),
                              dayBackgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return accentColor;
                                    }
                                    return Colors.transparent;
                                  }),
                              todayForegroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return accentForeground;
                                    }
                                    return accentColor;
                                  }),
                              todayBackgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return accentColor;
                                    }
                                    return currentTheme ==
                                                AppThemePreset.midnightBlack ||
                                            currentTheme ==
                                                AppThemePreset.carbonBlue
                                        ? accentColor.withValues(alpha: 0.22)
                                        : accentColor.withValues(
                                            alpha: isDark ? 0.14 : 0.10,
                                          );
                                  }),
                              todayBorder: BorderSide(
                                color: accentColor,
                                width: 1.4,
                              ),
                            ),
                          ),
                          child: CalendarDatePicker(
                            initialDate: selectedDate,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            onDateChanged: (value) {
                              setState(() {
                                selectedDate = _dateOnly(value);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              foregroundColor: isDark
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF111827),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text(
                              'Vazgec',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop(selectedDate);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: accentForeground,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text(
                              'Tarihi Sec',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String _formatDateLabel(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day.$month.$year';
  }
}
