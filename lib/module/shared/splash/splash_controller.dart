import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash screen duration (e.g. 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    // Get Auth status
    final authService = Get.find<AuthService>();
    final isLoggedIn = authService.isLoggedIn.value;

    // Check onboarding status
    final onboardingSeen = await StorageService.getBool(StorageConstants.onboardingSeen) ?? false;

    if (isLoggedIn) {
      // Get.offAllNamed(AppRoutes.bottomNavBar);
    } else if (!onboardingSeen) {
      // Get.offAllNamed(AppRoutes.onboarding);
    } else {
      // Get.offAllNamed(AppRoutes.login);
    }
  }
}
