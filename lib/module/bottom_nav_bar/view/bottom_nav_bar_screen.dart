import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive scaling factor 'k':
    // Scales proportionally on all screens (including phones and iPads/tablets) based on the design size width (393.0)
    // to ensure the navigation bar stays perfectly in proportion with the rest of the application.
    final double k = screenWidth / 393.0;

    // Sized symmetrically using the scaling factor 'k'
    final double barWidth = 361.0 * k;
    final double barHeight = 67.0 * k;

    return Center(
      child: Container(
        width: barWidth,
        height: barHeight + bottomPadding + 10.0 * k,
        padding: EdgeInsets.only(bottom: bottomPadding + 5.0 * k),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Custom Shape SVG
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: barHeight,
              child: SvgPicture.asset(
                'assets/icons/bottom _nab_ber.svg', // Fixed filename with space
                width: barWidth,
                height: barHeight,
                fit: BoxFit
                    .fill, // Ensures it stretches exactly to the specified bounds
              ),
            ),

            // Main Navigation Items (Home, Wishlist, Profile) - centered inside the left capsule, adjusted to shift Wishlist & Profile rightwards
            Positioned(
              left: 0,
              top: 0,
              width: 250.0 * k,
              height: barHeight,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 15.0 * k),
                    _buildNavItem(0, 'assets/icons/home.svg', k),
                    SizedBox(width: 38.0 * k), // Shift Wishlist to the right
                    _buildNavItem(1, 'assets/icons/wishlist.svg', k),
                    SizedBox(width: 38.0 * k), // Shift Profile to the right
                    _buildNavItem(2, 'assets/icons/profile.svg', k),
                  ],
                ),
              ),
            ),

            // Floating Action Button (+) centered mathematically on the SVG's cream circle
            Positioned(
              left: 301.0 * k,
              top: (barHeight - 53.0 * k) / 2,
              width: 53.0 * k,
              height: 53.0 * k,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5ECE7), // Cream background matching SVG
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Get.toNamed(AppRoutes.sell);
                    },
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: const Color(0xFF0F1012), // Black plus icon
                        size: 26.0 * k,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, double k) {
    final isSelected = controller.selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(12.0 * k),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFFffffff).withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: SvgPicture.asset(
          iconPath,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.white : const Color(0xffA2A2A2),
            BlendMode.srcIn,
          ),
          width: 26.0 * k,
          height: 26.0 * k,
        ),
      ),
    );
  }
}

// /// A CustomPainter that draws a perfectly symmetrical, continuous dark bottom bar
// /// containing a main navigation capsule, a narrow neck, and a matching circular capsule
// /// on the right for the floating action button.
// class BottomNavBarPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color =
//           const Color(0xFF0F1012) // Rich dark background matching screenshot
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color =
//           const Color(0xFF2E2E33) // Elegant subtle border matching design
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.2.w;

//     final path = Path();
//     final h = size.height;
//     final w = size.width;
//     final r = h / 2; // Semi-circle corner radius = 36 for h = 72

//     // Symmetrical circle center
//     final cx = w - r;
//     final cy = r;

//     // Mathematically exact start/end angles for the circular FAB capsule
//     const angleTop = 1.25 * math.pi;

//     // Transition connection coordinates at exact circle edge points
//     final tx1 = cx + r * math.cos(angleTop);
//     final ty1 = cy + r * math.sin(angleTop);

//     // Start top-left corner
//     path.moveTo(r, 0);

//     // Top edge of the main navigation pill
//     path.lineTo(w - 120, 0);

//     // Smooth curve down to the neck (symmetrical top curve)
//     path.cubicTo(
//       w - 105,
//       0,
//       w - 98,
//       28,
//       w - 86,
//       28, // Symmetrical Neck Center Top
//     );
//     path.cubicTo(
//       w - 74,
//       28,
//       w - 68,
//       14,
//       tx1,
//       ty1, // Merges perfectly into the start of the arc
//     );

//     // Draw the circular capsule on the right (centered at cx, cy)
//     path.arcTo(
//       Rect.fromCircle(center: Offset(cx, cy), radius: r),
//       angleTop,
//       1.5 * math.pi,
//       false,
//     );

//     // Smooth curve back to the neck bottom (symmetrical bottom curve)
//     path.cubicTo(
//       w - 68,
//       h - 14,
//       w - 74,
//       h - 28,
//       w - 86,
//       h - 28, // Symmetrical Neck Center Bottom
//     );
//     path.cubicTo(w - 98, h - 28, w - 105, h, w - 120, h);

//     // Bottom edge back to left corner
//     path.lineTo(r, h);
//     path.quadraticBezierTo(0, h, 0, h - r);
//     path.lineTo(0, r);
//     path.quadraticBezierTo(0, 0, r, 0);
//     path.close();

//     // Symmetrical outer shadow
//     canvas.drawShadow(
//       path.shift(const Offset(0, 4)),
//       Colors.black.withValues(alpha: 0.5),
//       10.0,
//       true,
//     );

//     // Draw solid background fill
//     canvas.drawPath(path, paint);

//     // Draw border outline
//     canvas.drawPath(path, borderPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
