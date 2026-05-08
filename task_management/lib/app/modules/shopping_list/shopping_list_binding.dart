import 'package:get/get.dart';

import 'shopping_list_controller.dart';

class ShoppingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShoppingListController>(() => ShoppingListController());
  }
}
