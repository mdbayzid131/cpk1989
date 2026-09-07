import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/internet_controller.dart';

class ConnectivityService {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void init() {
    // 1. Check initial connectivity on app boot
    checkInitialConnectivity();

    // 2. Real-time stream listener for network interface changes (iOS & Android)
    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      final isNone =
          results.contains(ConnectivityResult.none) || results.isEmpty;
      if (isNone) {
        if (Get.isRegistered<InternetController>()) {
          Get.find<InternetController>().setOffline();
        }
      } else {
        // Confirm real socket reachability on both iOS & Android
        final hasRealInternet = await checkInternet();
        if (Get.isRegistered<InternetController>()) {
          if (hasRealInternet) {
            Get.find<InternetController>().setOnline();
          } else {
            Get.find<InternetController>().setOffline();
          }
        }
      }
    });
  }

  static Future<void> checkInitialConnectivity() async {
    final hasInternet = await checkInternet();
    if (Get.isRegistered<InternetController>()) {
      if (!hasInternet) {
        Get.find<InternetController>().setOffline();
      } else {
        Get.find<InternetController>().setOnline();
      }
    }
  }

  /// Checks whether there is active, working internet connectivity across iOS & Android
  static Future<bool> checkInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) ||
          connectivityResult.isEmpty) {
        return false;
      }

      // Fast DNS lookup with multi-host fallback
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // Fallback for strict networks
        final fallbackResult = await InternetAddress.lookup('cloudflare.com')
            .timeout(const Duration(seconds: 3));
        if (fallbackResult.isNotEmpty && fallbackResult[0].rawAddress.isNotEmpty) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint("Connectivity check error: $e");
      return false;
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
