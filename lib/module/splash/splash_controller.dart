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
      await Future.delayed(const Duration(seconds: 3));
      final onboardingSeen =
          await StorageService.getBool(StorageConstants.onboardingSeen) ??
          false;
      if (!onboardingSeen) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.bottomNavBar);
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}
