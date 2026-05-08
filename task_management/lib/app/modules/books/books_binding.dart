import 'package:get/get.dart';

import 'books_controller.dart';

class BooksBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<BooksController>()) {
      Get.delete<BooksController>(force: true);
    }

    Get.put<BooksController>(BooksController());
  }
}
