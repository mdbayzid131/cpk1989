import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class StripeReturnView extends StatefulWidget {
  const StripeReturnView({super.key});

  @override
  State<StripeReturnView> createState() => _StripeReturnViewState();
}

class _StripeReturnViewState extends State<StripeReturnView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Switch to Profile tab (index 3)
      if (Get.isRegistered<BottomNavBarController>()) {
        Get.find<BottomNavBarController>().changeIndex(3);
      }

      // Switch to Personal Details tab (index 2) and refresh status
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        profileCtrl.changeTab(2);
        await profileCtrl.checkStripeConnectStatus();
        await profileCtrl.fetchProfileStats();
      }

      // Smoothly navigate back to main app
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.offAllNamed(AppRoutes.bottomNavBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1012),
      body: SizedBox.shrink(),
    );
  }
}
