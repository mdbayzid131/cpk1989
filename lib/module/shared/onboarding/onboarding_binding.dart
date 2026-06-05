import 'package:get/get.dart';
import 'package:cpk1989/module/shared/onboarding/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OnboardingController());
  }
}
