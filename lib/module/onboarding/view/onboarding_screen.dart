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
      backgroundColor: const Color(0xFF0A0A0C), // dark premium background
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
                    final double width = 10.w + (18.w * progress);

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: width,
                      height: 10.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        color: const Color(0xFF2E2E33), // Inactive background
                      ),
                      child: Opacity(
                        opacity: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.w),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFAF7413),
                                Color(0xFFC98C28),
                                Color(0xFFE2B744),
                                Color(0xFFFFED81),
                                Color(0xFFE1C24E),
                                Color(0xFFA06008),
                              ],
                              stops: [
                                0.0477,
                                0.1933,
                                0.3893,
                                0.5054,
                                0.6210,
                                0.9074,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
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
                width: _currentPage == 2 ? 180.w : 56.w,
                height: 56.w,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.r),
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
                  child: AnimatedCrossFade(
                    firstChild: SizedBox(
                      width: 180.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enter Closete',
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 20.w,
                          ),
                        ],
                      ),
                    ),
                    secondChild: SizedBox(
                      width: 56.w,
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 24.w,
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
        ],
      ),
    );
  }
}
