import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'bottom_nav_bar_controller.dart';
import 'pages/home_feed_page.dart';
import 'pages/placeholder_pages.dart';

class BottomNavBarView extends GetView<BottomNavBarController> {
  const BottomNavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pages corresponding to tabs
    final List<Widget> pages = [
      const HomeFeedPage(),
      const FavoritesPage(),
      const ProfilePage(),
      const AddListingPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012), // Deep charcoal black background
      body: Stack(
        children: [
          // 1. Page Content
          Obx(() => Positioned.fill(
                child: pages[controller.currentIndex.value],
              )),

          // 2. Custom Floating Frosted Bottom Navigation Bar
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 24.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 72.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16181B).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(40.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icons Group (Home, Favorites, Profile)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Home Tab
                            _buildNavBarItem(
                              index: 0,
                              activeIcon: Icons.home_filled,
                              inactiveIcon: Icons.home_outlined,
                            ),
                            // Favorites Tab
                            _buildNavBarItem(
                              index: 1,
                              activeIcon: Icons.favorite_rounded,
                              inactiveIcon: Icons.favorite_outline_rounded,
                            ),
                            // Profile Tab
                            _buildNavBarItem(
                              index: 2,
                              activeIcon: Icons.person_rounded,
                              inactiveIcon: Icons.person_outline_rounded,
                            ),
                          ],
                        ),
                      ),

                      // Spacing or divider before action button
                      VerticalDivider(
                        color: Colors.white.withValues(alpha: 0.1),
                        indent: 20.h,
                        endIndent: 20.h,
                        width: 1,
                      ),
                      SizedBox(width: 12.w),

                      // White Floating Action Button on the right
                      Obx(() {
                        final isAddActive = controller.currentIndex.value == 3;
                        return GestureDetector(
                          onTap: () => controller.changeIndex(3),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAddActive ? const Color(0xFFD4AF37) : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: isAddActive
                                      ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                                      : Colors.black26,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: isAddActive ? Colors.white : Colors.black,
                              size: 26.sp,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper builder for custom nav bar icons
  Widget _buildNavBarItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
            size: 26.sp,
          ),
        ),
      );
    });
  }
}
