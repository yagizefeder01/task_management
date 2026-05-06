import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/core/theme/app_themes.dart';
import 'app/core/translations/app_translations.dart';
import 'app/data/models/task_model.dart';
import 'app/data/services/theme_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());

  await ThemeService.init();

  runApp(const FocusLocalApp());
}

class FocusLocalApp extends StatelessWidget {
  const FocusLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusLocal',
      locale: ThemeService.currentLocale,
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeService.themeMode,
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
  }
}
