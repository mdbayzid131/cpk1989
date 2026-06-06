import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/home/view/home_screen.dart';
import 'package:cpk1989/module/wishlist/view/wishlist_screen.dart';
import 'package:cpk1989/module/profile/view/profile_screen.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

class BottomNavBarScreen extends GetView<BottomNavBarController> {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const HomeScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Stack(
        children: [
          // Current selected tab content (Full Bleed)
          Obx(() => tabs[controller.selectedIndex]),

          // Floating Custom Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = 72.0;
    // Calculate total width of the bottom bar container inside its padding (padding is 20 left, 20 right)
    final w = MediaQuery.of(context).size.width - 40;

    return Container(
      height: barHeight + bottomPadding + 20.h,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding + 10.h,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Custom Shape
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barHeight,
            child: CustomPaint(painter: BottomNavBarPainter()),
          ),

          // Main Navigation Items (Home, Wishlist, Profile)
          Positioned(
            left: 12,
            top: 0,
            width: w - 120,
            height: barHeight,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home),
                  _buildNavItem(1, Icons.favorite_border, Icons.favorite),
                  _buildNavItem(2, Icons.person_outline, Icons.person),
                ],
              ),
            ),
          ),

          // Floating Action Button (+) centered mathematically in the right circular capsule
          Positioned(
            right: 12,
            top: (barHeight - 48) / 2,
            width: 48,
            height: 48,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(
                  0xFFF6EFE9,
                ), // Creamy accent background matching design
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Get.toNamed(AppRoutes.sell);
                  },
                  child: const Icon(Icons.add, color: Colors.black, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
  ) {
    final isSelected = controller.selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF282A2E) : Colors.transparent,
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? Colors.white : const Color(0xff8E8E93),
          size: 24.sp,
        ),
      ),
    );
  }
}

/// A CustomPainter that draws a perfectly symmetrical, continuous dark bottom bar
/// containing a main navigation capsule, a narrow neck, and a matching circular capsule
/// on the right for the floating action button.
class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF111214) // Clean dark background matching screenshot
      ..style = PaintingStyle.fill;

    final path = Path();
    final h = size.height;
    final w = size.width;
    final r = h / 2; // Semi-circle corner radius = 36 for h = 72

    // Symmetrical circle center
    final cx = w - r;
    final cy = r;

    // Mathematically exact start/end angles for the circular FAB capsule
    const angleTop = 1.25 * math.pi;

    // Transition connection coordinates at exact circle edge points
    final tx1 = cx + r * math.cos(angleTop);
    final ty1 = cy + r * math.sin(angleTop);

    // Start top-left corner
    path.moveTo(r, 0);

    // Top edge of the main navigation pill
    path.lineTo(w - 120, 0);

    // Smooth curve down to the neck (symmetrical top curve)
    path.cubicTo(
      w - 105,
      0,
      w - 98,
      28,
      w - 86,
      28, // Symmetrical Neck Center Top
    );
    path.cubicTo(
      w - 74,
      28,
      w - 68,
      14,
      tx1,
      ty1, // Merges perfectly into the start of the arc
    );

    // Draw the circular capsule on the right (centered at cx, cy)
    path.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      angleTop,
      1.5 * math.pi,
      false,
    );

    // Smooth curve back to the neck bottom (symmetrical bottom curve)
    path.cubicTo(
      w - 68,
      h - 14,
      w - 74,
      h - 28,
      w - 86,
      h - 28, // Symmetrical Neck Center Bottom
    );
    path.cubicTo(w - 98, h - 28, w - 105, h, w - 120, h);

    // Bottom edge back to left corner
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    // Symmetrical outer shadow
    canvas.drawShadow(
      path.shift(const Offset(0, 4)),
      Colors.black.withValues(alpha: 0.5),
      10.0,
      true,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
