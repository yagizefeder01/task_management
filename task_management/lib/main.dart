import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/core/translations/app_translations.dart';
import 'app/data/models/task_model.dart';
import 'app/data/services/ad_service.dart';
import 'app/data/services/daily_task_reset_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());

  await ThemeService.init();
  await NotificationService.init();
  await AdService.initialize();
  await DailyTaskResetService.ensureResetIfNeeded();

  runApp(const ClutchFlowApp());
}

class ClutchFlowApp extends StatefulWidget {
  const ClutchFlowApp({super.key});

  @override
  State<ClutchFlowApp> createState() => _ClutchFlowAppState();
}

class _ClutchFlowAppState extends State<ClutchFlowApp> {
  AppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(onResume: _handleAppResume);
  }

  Future<void> _handleAppResume() async {
    await DailyTaskResetService.ensureResetIfNeeded();
    await DailyTaskResetService.refreshHomeIfOpen();
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeTheme = ThemeService.activeThemeData;

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ClutchFlow',
        locale: ThemeService.currentLocale,
        translations: AppTranslations(),
        fallbackLocale: const Locale('en', 'US'),
        theme: activeTheme,
        darkTheme: activeTheme,
        themeMode: activeTheme.brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr'),
          Locale('en'),
          Locale('zh'),
          Locale('hi'),
          Locale('es'),
          Locale('pt'),
          Locale('fr'),
          Locale('ar'),
          Locale('ru'),
          Locale('de'),
        ],
      );
    });
  }
}
