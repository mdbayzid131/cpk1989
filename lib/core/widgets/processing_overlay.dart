import 'package:flutter/material.dart';
import 'package:cpk1989/core/utils/helpers.dart';

/// Global static helper to show a standardized gold processing overlay.
/// Uses the unified [Helpers.showLoadingDialog] for complete consistency.
Future<void> showProcessingOverlay(
  BuildContext context,
  VoidCallback onComplete, {
  Future<void> Function()? asyncTask,
}) async {
  Helpers.showLoadingDialog(message: "Processing..");

  try {
    if (asyncTask != null) {
      final startTime = DateTime.now();
      await asyncTask();
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 1200) {
        await Future.delayed(Duration(milliseconds: 1200 - elapsed));
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  } finally {
    Helpers.hideLoadingDialog();
  }
  onComplete();
}
