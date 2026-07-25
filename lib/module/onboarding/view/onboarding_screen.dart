import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/constants/storage_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_1.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_2.dart';
import 'package:cpk1989/module/onboarding/view/onboarding_page_3.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/config/themes/app_theme.dart';

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
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.hasClients) {
      final page = _pageController.page ?? 0.0;
      final targetPage = page.round();
      if (targetPage != _currentPage) {
        setState(() {
          _currentPage = targetPage;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012), // dark premium background
      body: Stack(
        children: [
          // 1. Full screen PageView (allows background elements to bleed into edges)
          Positioned.fill(
            child: PageView(
              controller: _pageController,
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
                  Get.offAllNamed(AppRoutes.login);
                },
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 50.h,
            left: 24.w,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                final page = _pageController.hasClients
                    ? (_pageController.page ?? 0.0)
                    : 0.0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final double distance = (page - index).abs();
                    final double progress = (1.0 - distance).clamp(0.0, 1.0);
                    final double width = 6.w + (12.w * progress);

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: width,
                      height: 6.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.w),
                        color: const Color(0xFF2E2E33), // Inactive background
                      ),
                      child: Opacity(
                        opacity: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.w),
                            gradient: AppTheme.goldGradient,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
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
                  Get.offAllNamed(AppRoutes.login);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: _currentPage == 2 ? 158.w : 46.h,
                height: 46.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE2B744).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                    gradient: AppTheme.goldGradient,
                  ),
                  child: Center(
                    child: AnimatedCrossFade(
                      firstChild: SizedBox(
                        width: 156.w,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Enter Closete',
                                maxLines: 1,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F1012),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF0F1012),
                                size: 18.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      secondChild: SizedBox(
                        width: 46.h,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 22.w,
                          ),
                        ),
                      ),
                      crossFadeState: _currentPage == 2
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
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
