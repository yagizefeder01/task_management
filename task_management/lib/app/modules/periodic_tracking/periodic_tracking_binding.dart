import 'package:get/get.dart';

import 'periodic_tracking_controller.dart';

class PeriodicTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PeriodicTrackingController>(() => PeriodicTrackingController());
  }
}
