import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

/// Shared destination for push taps and the in-app notification list.
void openProfilePayoutDetails() {
  void selectPayout() {
    if (Get.isRegistered<BottomNavBarController>() &&
        Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().focusPayoutDetails();
      Get.find<BottomNavBarController>().changeIndex(3);
    }
  }

  if (Get.isRegistered<BottomNavBarController>()) {
    Get.until((route) => route.settings.name == AppRoutes.bottomNavBar);
    selectPayout();
  } else {
    Get.offAllNamed(AppRoutes.bottomNavBar);
    WidgetsBinding.instance.addPostFrameCallback((_) => selectPayout());
  }
}
