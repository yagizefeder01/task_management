import 'package:get/get.dart';

import '../modules/books/books_binding.dart';
import '../modules/books/books_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/launch/launch_binding.dart';
import '../modules/launch/launch_view.dart';
import '../modules/periodic_tracking/periodic_tracking_binding.dart';
import '../modules/periodic_tracking/periodic_tracking_view.dart';
import '../modules/shopping_list/shopping_list_binding.dart';
import '../modules/shopping_list/shopping_list_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/task_detail/task_detail_binding.dart';
import '../modules/task_detail/task_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.launch;

  static final pages = [
    GetPage(
      name: AppRoutes.launch,
      page: () => const LaunchView(),
      binding: LaunchBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.books,
      page: () => const BooksView(),
      binding: BooksBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRoutes.shoppingList,
      page: () => const ShoppingListView(),
      binding: ShoppingListBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRoutes.periodicTracking,
      page: () => const PeriodicTrackingView(),
      binding: PeriodicTrackingBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: AppRoutes.taskDetail,
      page: () => const TaskDetailView(),
      binding: TaskDetailBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.downToUp,
    ),
  ];
}
