import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_themes.dart';
import '../../data/services/theme_service.dart';
import '../../routes/app_routes.dart';

class AppSideDrawer extends StatelessWidget {
  const AppSideDrawer({super.key});

  void _goTo(String route) {
    if (Get.currentRoute == route) {
      Get.back();
      return;
    }
    Get.back();
    Get.offNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final iconPalette = AppThemes.iconPaletteFor(
      ThemeService.currentTheme.value,
    );
    final Color drawerBackground = theme.scaffoldBackgroundColor;
    final Color headerBackground = theme.cardColor;
    final Color borderColor = theme.surfaceBorderColor;
    final Color iconAccent = iconPalette.navigation;
    final Color textColor = colorScheme.onSurface;
    final Color brandColor = Color.lerp(
      iconPalette.navigation,
      colorScheme.onSurface,
      isDark ? 0.22 : 0.42,
    )!;
    final Color selectedTileColor = colorScheme.secondary.withValues(
      alpha: isDark ? 0.18 : 0.10,
    );
    final String currentRoute = Get.currentRoute;

    return Drawer(
      backgroundColor: drawerBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                color: headerBackground,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'app_name'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontSize: 31,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: brandColor,
                    shadows: [
                      Shadow(
                        color: brandColor.withValues(
                          alpha: isDark ? 0.34 : 0.18,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.home_rounded, color: iconAccent),
              title: Text(
                'launch_home'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.launch,
              selectedColor: iconAccent,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.launch),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Icon(Icons.checklist_rounded, color: iconPalette.tasks),
              title: Text(
                'home_title'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.home,
              selectedColor: iconPalette.tasks,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.home),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Icon(Icons.menu_book_rounded, color: iconPalette.tasks),
              title: Text(
                'bookshelf_title'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.books,
              selectedColor: iconPalette.tasks,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.books),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Icon(
                Icons.shopping_bag_rounded,
                color: iconPalette.shopping,
              ),
              title: Text(
                'shopping_list'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.shoppingList,
              selectedColor: iconPalette.shopping,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.shoppingList),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Icon(
                Icons.autorenew_rounded,
                color: iconPalette.periodic,
              ),
              title: Text(
                'periodic_tracking'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.periodicTracking,
              selectedColor: iconPalette.periodic,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.periodicTracking),
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Icon(
                Icons.settings_rounded,
                color: iconPalette.settings,
              ),
              title: Text(
                'settings_title'.tr,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              selected: currentRoute == AppRoutes.settings,
              selectedColor: iconPalette.settings,
              selectedTileColor: selectedTileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => _goTo(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
