import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_1.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_2.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_3.dart';

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
      backgroundColor: const Color(0xFF0A0A0C), // dark premium background
      body: Stack(
        children: [
          // 1. Full screen PageView (allows background elements to bleed into edges)
          Positioned.fill(
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

          // 2. Floating Skip Button at the top-left (only visible if not on the last page)
          if (_currentPage < 2)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () async {
                  await StorageService.setBool(
                    StorageConstants.onboardingSeen,
                    true,
                  );
                  Get.offAllNamed(AppRoutes.bottomNavBar);
                },
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),

          // 3. Floating Page Indicator at the bottom-left
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40.h,
            left: 24.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentPage == index
                        ? const Color(0xFFE2B744) // Active gold
                        : Colors.white.withValues(alpha: 0.15), // Inactive grey
                  ),
                ),
              ),
            ),
          ),

          // 4. Floating Circular Gold Action Button at the bottom-right
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30.h,
            right: 24.w,
            child: GestureDetector(
              onTap: () async {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                } else {
                  await StorageService.setBool(
                    StorageConstants.onboardingSeen,
                    true,
                  );
                  Get.offAllNamed(AppRoutes.bottomNavBar);
                }
              },
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAF7413),
                      Color(0xFFC98C28),
                      Color(0xFFE2B744),
                      Color(0xFFFFED81),
                      Color(0xFFE1C24E),
                      Color(0xFFA06008),
                    ],
                    stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE2B744).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 24.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
