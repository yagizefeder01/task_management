import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class LaunchController extends GetxController {
  void goToTasks() => Get.offNamed(AppRoutes.home);

  void goToBooks() => Get.offNamed(AppRoutes.books);

  void goToShoppingList() => Get.offNamed(AppRoutes.shoppingList);

  void goToPeriodicTracking() => Get.offNamed(AppRoutes.periodicTracking);

  void goToSettings() => Get.toNamed(AppRoutes.settings);
}
