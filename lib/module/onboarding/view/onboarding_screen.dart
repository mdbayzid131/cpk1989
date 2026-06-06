import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_1.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_2.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_3.dart';

import 'package:cpk1989/core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  ///<================= PAGE CONTROLLER =========================>///
  final PageController _pageController = PageController();

  ///<================= CURRENT PAGE INDEX =========================>///
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///<================= BODY =========================>///
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              ///<================= PAGE VIEW =========================>///
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: const [
                    OnboardingPage1(),
                    OnboardingPage2(),
                    OnboardingPage3(),
                  ],
                ),
              ),

              ///<================= BOTTOM SECTION =========================>///
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///<================= BUTTON SECTION =========================>///
                  CustomButton(
                    text: _currentPage == 2 ? "Get Started" : "Continue",
                    onPressed: () async {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        await StorageService.setBool(
                          StorageConstants.onboardingSeen,
                          true,
                        );

                        Get.offAllNamed(AppRoutes.bottomNavBar);
                      }
                    },
                  ),

                  SizedBox(height: 24.h),

                  ///<================= PAGE INDICATOR =========================>///
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 28.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
