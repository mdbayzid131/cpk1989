import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      print("SplashController: Waiting for 3 seconds...");
      await Future.delayed(const Duration(seconds: 3));
      print("SplashController: Checking auth status...");
      final authService = Get.find<AuthService>();
      final isLoggedIn = authService.isLoggedIn.value;
      print("SplashController: isLoggedIn = $isLoggedIn");

      print("SplashController: Checking onboardingSeen status...");
      final onboardingSeen = await StorageService.getBool(StorageConstants.onboardingSeen) ?? false;
      print("SplashController: onboardingSeen = $onboardingSeen");

      if (isLoggedIn) {
        print("SplashController: Navigating to bottomNavBar");
        Get.offAllNamed(AppRoutes.bottomNavBar);
      } else if (!onboardingSeen) {
        print("SplashController: Navigating to onboarding");
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        print("SplashController: Navigating to login");
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e, stack) {
      print("ERROR IN SPLASH NAVIGATION: $e");
      print(stack);
    }
  }
}
