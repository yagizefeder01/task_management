import 'package:flutter/services.dart';

class HapticService {
  HapticService._();

  static Future<void> vibration() async {
    await HapticFeedback.lightImpact();
  }
}
