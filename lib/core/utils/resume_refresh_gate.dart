import 'package:flutter/widgets.dart';

/// Ignore native checkout overlays; reconcile once after real backgrounding.
class ResumeRefreshGate {
  bool _wasPaused = false;

  bool shouldRefresh(AppLifecycleState state, {bool checkoutActive = false}) {
    if (state == AppLifecycleState.paused) _wasPaused = true;
    if (state != AppLifecycleState.resumed) return false;
    final wasPaused = _wasPaused;
    _wasPaused = false;
    return !checkoutActive && wasPaused;
  }
}
