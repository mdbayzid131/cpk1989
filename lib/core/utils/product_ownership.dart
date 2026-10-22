import 'package:get/get.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

bool isOwnProduct(String sellerId) {
  if (!Get.isRegistered<ProfileController>()) return false;
  final userId = Get.find<ProfileController>().rxUserId.value;
  return userId.isNotEmpty && sellerId == userId;
}

bool canSecureProduct(String sellerId) {
  if (!Get.isRegistered<ProfileController>()) return false;
  final userId = Get.find<ProfileController>().rxUserId.value;
  return userId.isNotEmpty && sellerId.isNotEmpty && sellerId != userId;
}

void openOwnProfile() {
  Get.until((route) => route.settings.name == AppRoutes.bottomNavBar);
  Get.find<BottomNavBarController>().changeIndex(3);
}
