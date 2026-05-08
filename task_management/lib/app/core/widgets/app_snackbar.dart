import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_themes.dart';

class AppSnackbar {
  static void showSuccess(String title, String message) {
    final theme = Get.theme;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.semanticPalette.snackbarSuccess,
      colorText: theme.semanticPalette.onAccent,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String title, String message) {
    final theme = Get.theme;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.semanticPalette.snackbarDanger,
      colorText: theme.semanticPalette.onDanger,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }

  static void showDelete(
    String title,
    String message, {
    FutureOr<void> Function()? onUndo,
    Color? backgroundColor,
  }) {
    final theme = Get.theme;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? theme.semanticPalette.snackbarDanger,
      colorText: theme.semanticPalette.onDanger,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      mainButton: onUndo == null
          ? null
          : TextButton(
              onPressed: () async {
                Get.closeCurrentSnackbar();
                await onUndo();
              },
              child: Text(
                'undo'.tr,
                style: TextStyle(
                  color: theme.semanticPalette.onDanger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
