import 'package:get/get.dart';

import 'launch_controller.dart';

class LaunchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaunchController>(() => LaunchController());
  }
}
