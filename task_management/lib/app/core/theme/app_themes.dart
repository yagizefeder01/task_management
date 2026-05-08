import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_styles.dart';

enum AppThemePreset { royalIvory, midnightBlack, matteBlack, carbonBlue }

class AppThemeIconPalette {
  const AppThemeIconPalette({
    required this.navigation,
    required this.tasks,
    required this.shopping,
    required this.periodic,
    required this.settings,
  });

  final Color navigation;
  final Color tasks;
  final Color shopping;
  final Color periodic;
  final Color settings;
}

class AppThemePreviewPalette {
  const AppThemePreviewPalette({required this.primary, required this.accent});

  final Color primary;
  final Color accent;
}

class AppSurfacePalette extends ThemeExtension<AppSurfacePalette> {
  const AppSurfacePalette({required this.cardBorder});

  final Color cardBorder;

  @override
  AppSurfacePalette copyWith({Color? cardBorder}) {
    return AppSurfacePalette(cardBorder: cardBorder ?? this.cardBorder);
  }

  @override
  AppSurfacePalette lerp(
    covariant ThemeExtension<AppSurfacePalette>? other,
    double t,
  ) {
    if (other is! AppSurfacePalette) {
      return this;
    }

    return AppSurfacePalette(
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
    );
  }
}

class AppTaskPriorityTone {
  const AppTaskPriorityTone({
    required this.background,
    required this.border,
    required this.accent,
  });

  final Color background;
  final Color border;
  final Color accent;

  AppTaskPriorityTone copyWith({
    Color? background,
    Color? border,
    Color? accent,
  }) {
    return AppTaskPriorityTone(
      background: background ?? this.background,
      border: border ?? this.border,
      accent: accent ?? this.accent,
    );
  }

  static AppTaskPriorityTone lerp(
    AppTaskPriorityTone a,
    AppTaskPriorityTone b,
    double t,
  ) {
    return AppTaskPriorityTone(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      border: Color.lerp(a.border, b.border, t) ?? a.border,
      accent: Color.lerp(a.accent, b.accent, t) ?? a.accent,
    );
  }
}

class AppTaskPalette extends ThemeExtension<AppTaskPalette> {
  const AppTaskPalette({
    required this.high,
    required this.medium,
    required this.low,
  });

  final AppTaskPriorityTone high;
  final AppTaskPriorityTone medium;
  final AppTaskPriorityTone low;

  AppTaskPriorityTone toneForPriority(int priority) {
    switch (priority) {
      case 3:
        return high;
      case 2:
        return medium;
      default:
        return low;
    }
  }

  @override
  AppTaskPalette copyWith({
    AppTaskPriorityTone? high,
    AppTaskPriorityTone? medium,
    AppTaskPriorityTone? low,
  }) {
    return AppTaskPalette(
      high: high ?? this.high,
      medium: medium ?? this.medium,
      low: low ?? this.low,
    );
  }

  @override
  AppTaskPalette lerp(
    covariant ThemeExtension<AppTaskPalette>? other,
    double t,
  ) {
    if (other is! AppTaskPalette) {
      return this;
    }

    return AppTaskPalette(
      high: AppTaskPriorityTone.lerp(high, other.high, t),
      medium: AppTaskPriorityTone.lerp(medium, other.medium, t),
      low: AppTaskPriorityTone.lerp(low, other.low, t),
    );
  }
}

extension AppThemeSurfaceExtension on ThemeData {
  AppSurfacePalette get surfacePalette =>
      extension<AppSurfacePalette>() ??
      AppSurfacePalette(
        cardBorder: AppThemes.surfaceBorderFor(
          cardColor,
          brightness: brightness,
        ),
      );

  Color get surfaceBorderColor => surfacePalette.cardBorder;

  AppTaskPalette get taskPalette =>
      extension<AppTaskPalette>() ??
      AppThemes.buildTaskPalette(cardColor, brightness: brightness);
}

class AppThemes {
  AppThemes._();

  static const List<AppThemePreset> presets = AppThemePreset.values;

  static ThemeData get lightTheme => themeFor(AppThemePreset.royalIvory);

  static ThemeData get darkTheme => themeFor(AppThemePreset.midnightBlack);

  static ThemeData get carbonTheme => themeFor(AppThemePreset.carbonBlue);

  static AppThemeIconPalette iconPaletteFor(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.royalIvory:
        return const AppThemeIconPalette(
          navigation: Color(0xFF7C5A2F),
          tasks: Color(0xFF7C5A2F),
          shopping: Color(0xFF7C5A2F),
          periodic: Color(0xFF7C5A2F),
          settings: Color(0xFF7C5A2F),
        );
      case AppThemePreset.midnightBlack:
        return const AppThemeIconPalette(
          navigation: Color(0xFFEAB308),
          tasks: Color(0xFFEAB308),
          shopping: Color(0xFFEAB308),
          periodic: Color(0xFFEAB308),
          settings: Color(0xFFEAB308),
        );
      case AppThemePreset.matteBlack:
        return const AppThemeIconPalette(
          navigation: Color(0xFF8DD3C7),
          tasks: Color(0xFF8DD3C7),
          shopping: Color(0xFF8DD3C7),
          periodic: Color(0xFF8DD3C7),
          settings: Color(0xFF8DD3C7),
        );
      case AppThemePreset.carbonBlue:
        return const AppThemeIconPalette(
          navigation: Color(0xFFE0F2FE),
          tasks: Color(0xFFE0F2FE),
          shopping: Color(0xFFE0F2FE),
          periodic: Color(0xFFE0F2FE),
          settings: Color(0xFFE0F2FE),
        );
    }
  }

  static AppThemePreviewPalette previewPaletteFor(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.royalIvory:
        return const AppThemePreviewPalette(
          primary: Color(0xFFF6F1E8),
          accent: Color(0xFFA86F2D),
        );
      case AppThemePreset.midnightBlack:
        return const AppThemePreviewPalette(
          primary: Color(0xFF09090B),
          accent: Color(0xFFEAB308),
        );
      case AppThemePreset.matteBlack:
        return const AppThemePreviewPalette(
          primary: Color(0xFF171717),
          accent: Color(0xFF8DD3C7),
        );
      case AppThemePreset.carbonBlue:
        return const AppThemePreviewPalette(
          primary: Color(0xFF0F172A),
          accent: Color(0xFFE0F2FE),
        );
    }
  }

  static ThemeData themeFor(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.royalIvory:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF8B5E34),
          secondary: const Color(0xFFD7B98C),
          surface: const Color(0xFFFFFBF5),
          background: const Color(0xFFF6F1E8),
          cardColor: const Color(0xFFFFFCF7),
          accent: const Color(0xFFA86F2D),
          appBarBackground: const Color(0xFFF6F1E8),
          appBarForeground: const Color(0xFF201A17),
          iconColor: const Color(0xFF7C5A2F),
          shadowColor: const Color(0x40201A17),
        );
      case AppThemePreset.midnightBlack:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF09090B),
          secondary: const Color(0xFF8B6A16),
          surface: const Color(0xFF15110A),
          background: const Color(0xFF080603),
          cardColor: const Color(0xFF17120B),
          accent: const Color(0xFFEAB308),
          appBarBackground: const Color(0xFF09090B),
          appBarForeground: Colors.white,
          iconColor: const Color(0xFFEAB308),
          shadowColor: const Color(0x66000000),
        );
      case AppThemePreset.matteBlack:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF171717),
          secondary: const Color(0xFF262626),
          surface: const Color(0xFF202020),
          background: const Color(0xFF121212),
          cardColor: const Color(0xFF1C1C1C),
          accent: const Color(0xFF8DD3C7),
          appBarBackground: const Color(0xFF171717),
          appBarForeground: Colors.white,
          iconColor: const Color(0xFF8DD3C7),
          shadowColor: const Color(0x5A000000),
        );
      case AppThemePreset.carbonBlue:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF1D4ED8),
          surface: const Color(0xFF111827),
          background: const Color(0xFF020617),
          cardColor: const Color(0xFF0F172A),
          accent: const Color(0xFF38BDF8),
          appBarBackground: const Color(0xFF0F172A),
          appBarForeground: Colors.white,
          iconColor: const Color(0xFFE0F2FE),
          shadowColor: const Color(0x66000000),
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
    required Color cardColor,
    required Color accent,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color? iconColor,
    required Color shadowColor,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final Color onSurface = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF201A17);
    final Color cardBorder = surfaceBorderFor(
      cardColor,
      brightness: brightness,
    );
    final AppTaskPalette taskPalette = buildTaskPalette(
      cardColor,
      brightness: brightness,
    );
    final Color darkTint = secondary.withValues(alpha: 0.18);
    final Color darkBorder = secondary.withValues(alpha: 0.34);
    final Color darkSoftFill = secondary.withValues(alpha: 0.10);

    final TextTheme baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[
        AppSurfacePalette(cardBorder: cardBorder),
        taskPalette,
      ],
      shadowColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      canvasColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: iconColor == null ? null : IconThemeData(color: iconColor),
        actionsIconTheme: iconColor == null
            ? null
            : IconThemeData(color: iconColor),
      ),
      iconTheme: iconColor == null ? null : IconThemeData(color: iconColor),
      primaryIconTheme: iconColor == null
          ? null
          : IconThemeData(color: iconColor),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: cardBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: background,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSoftFill : primary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? darkBorder : primary.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? accent : primary, width: 1.4),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: TextStyles.heading.copyWith(color: onSurface),
        titleLarge: TextStyles.title.copyWith(color: onSurface),
        bodyMedium: TextStyles.body.copyWith(color: onSurface),
        labelLarge: TextStyles.label.copyWith(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? darkTint : primary.withOpacity(0.08),
        selectedColor: accent,
        disabledColor: isDark
            ? secondary.withValues(alpha: 0.08)
            : Colors.black.withOpacity(0.04),
        secondarySelectedColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerColor: isDark ? darkBorder : primary.withOpacity(0.10),
      splashColor: isDark ? secondary.withValues(alpha: 0.12) : null,
      highlightColor: isDark ? secondary.withValues(alpha: 0.08) : null,
    );
  }

  static Color surfaceBorderFor(
    Color surfaceColor, {
    required Brightness brightness,
  }) {
    final Color tint = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.black.withValues(alpha: 0.035);

    return Color.alphaBlend(tint, surfaceColor);
  }

  static AppTaskPalette buildTaskPalette(
    Color cardColor, {
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return AppTaskPalette(
      high: _taskPriorityTone(
        cardColor,
        brightness: brightness,
        accent: isDark ? const Color(0xFFF87171) : const Color(0xFFB42318),
        tintOpacity: isDark ? 0.10 : 0.035,
      ),
      medium: _taskPriorityTone(
        cardColor,
        brightness: brightness,
        accent: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB54708),
        tintOpacity: isDark ? 0.10 : 0.04,
      ),
      low: _taskPriorityTone(
        cardColor,
        brightness: brightness,
        accent: isDark ? const Color(0xFF34D399) : const Color(0xFF027A48),
        tintOpacity: isDark ? 0.10 : 0.04,
      ),
    );
  }

  static AppTaskPriorityTone _taskPriorityTone(
    Color cardColor, {
    required Brightness brightness,
    required Color accent,
    required double tintOpacity,
  }) {
    final Color background = Color.alphaBlend(
      accent.withValues(alpha: tintOpacity),
      cardColor,
    );

    return AppTaskPriorityTone(
      background: background,
      border: surfaceBorderFor(background, brightness: brightness),
      accent: accent,
    );
  }
}
