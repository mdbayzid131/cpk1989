import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/services/connectivity_service.dart';

class InternetController extends GetxController with WidgetsBindingObserver {
  static InternetController get to => Get.find<InternetController>();

  final hasInternet = true.obs;
  final isShowingNoInternet = false.obs;
  final isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background (e.g. user toggled Wi-Fi / Cellular in iOS/Android settings)
    if (state == AppLifecycleState.resumed) {
      ConnectivityService.checkInitialConnectivity();
    }
  }

  void setOffline() {
    hasInternet.value = false;
    showNoInternetBottomSheet();
  }

  void setOnline() {
    hasInternet.value = true;
    hideNoInternetBottomSheet();
  }

  void showNoInternetBottomSheet() {
    if (isShowingNoInternet.value) return;
    
    final context = Get.context ?? Get.key.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNoInternetBottomSheet();
      });
      return;
    }

    isShowingNoInternet.value = true;

    Get.bottomSheet(
      PopScope(
        canPop: false, // Disallow closing with hardware/gesture back button while offline
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111214),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Satellite Illustration SVG
                    SvgPicture.asset(
                      'assets/icons/no_internate.svg',
                      width: 140.r,
                      height: 140.r,
                    ),
                    SizedBox(height: 18.h),

                    // Title: "You're offline" (Cormorant Garamond)
                    Text(
                      "You're offline",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle: "Reconnect to continue exploring luxury" (DM Sans)
                    Text(
                      "Reconnect to continue exploring luxury",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 26.h),

                    // Try Again Button
                    Obx(
                      () => CustomGoldButton(
                        text: isChecking.value ? "Checking..." : "Try Again",
                        suffix: isChecking.value
                            ? SizedBox(
                                width: 16.r,
                                height: 16.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_rounded,
                                size: 16.r,
                                color: Colors.black,
                              ),
                        onTap: isChecking.value ? null : handleRetry,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((_) {
      isShowingNoInternet.value = false;
    });
  }

  void hideNoInternetBottomSheet() {
    if (isShowingNoInternet.value) {
      isShowingNoInternet.value = false;
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
    }
  }

  Future<void> handleRetry() async {
    isChecking.value = true;
    final isOnline = await ConnectivityService.checkInternet();
    isChecking.value = false;

    if (isOnline) {
      setOnline();
      Get.snackbar(
        'Connected',
        'Internet connection restored.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'No connection',
        "You're still offline, please check your internet connection.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: const Color(0xFFFF5252),
        duration: const Duration(seconds: 2),
      );
    }
  }
}
