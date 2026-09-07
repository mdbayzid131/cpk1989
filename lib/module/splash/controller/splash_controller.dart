import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/controllers/internet_controller.dart';
import 'package:cpk1989/core/services/connectivity_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // 1. Check internet connectivity on startup
      final isOnline = await ConnectivityService.checkInternet();
      if (!isOnline) {
        if (Get.isRegistered<InternetController>()) {
          InternetController.to.setOffline();
        }
        // Wait until internet is restored
        await _waitForInternet();
      }

      final onboardingSeen =
          await StorageService.getBool(StorageConstants.onboardingSeen) ??
          false;
      final isLoggedIn =
          await StorageService.getBool(StorageConstants.isLoggedIn) ?? false;
      if (!onboardingSeen) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else if (!isLoggedIn) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.bottomNavBar);
      }
    } catch (e) {
      debugPrint("Error in splash transition: $e");
    }
  }

  Future<void> _waitForInternet() async {
    while (Get.isRegistered<InternetController>() &&
        !InternetController.to.hasInternet.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
