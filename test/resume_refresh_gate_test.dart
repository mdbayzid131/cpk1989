import 'package:cpk1989/core/utils/resume_refresh_gate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native overlays and checkout resume do not refresh APIs', () {
    final gate = ResumeRefreshGate();
    expect(gate.shouldRefresh(AppLifecycleState.inactive), false);
    expect(gate.shouldRefresh(AppLifecycleState.resumed), false);
    gate.shouldRefresh(AppLifecycleState.paused);
    expect(
      gate.shouldRefresh(AppLifecycleState.resumed, checkoutActive: true),
      false,
    );
  });

  test('real background interval reconciles once on return', () {
    final gate = ResumeRefreshGate();
    gate.shouldRefresh(AppLifecycleState.paused);
    expect(gate.shouldRefresh(AppLifecycleState.resumed), true);
    expect(gate.shouldRefresh(AppLifecycleState.resumed), false);
  });
}
