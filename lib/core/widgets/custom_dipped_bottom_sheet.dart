import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable custom premium bottom sheet featuring:
/// - A central U-shaped dip on the top edge (drawn with a CustomPainter).
/// - A floating circular logo/badge centered on the dip.
/// - Background gold rays/glow effect behind the logo.
/// - Automatic keyboard avoidance.
class CustomDippedBottomSheet extends StatelessWidget {
  final Widget logo;
  final Widget content;

  const CustomDippedBottomSheet({
    super.key,
    required this.logo,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final double logoSize = 84.r;
    final double halfLogo = logoSize / 2;

    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Gold spotlight glow effect behind the logo (centered exactly on the logo center)
          Positioned(
            top:
                42.r -
                90.r, // Centered vertically on the logo center (y = 42.r) with radius 90.r
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 180.r,
                height: 180.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFE2B744,
                      ).withValues(alpha: 0.55), // Brighter central light
                      const Color(0xFFE2B744).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. Dipped top card container (shifted down by half the logo size)
          Padding(
            padding: EdgeInsets.only(top: halfLogo),
            child: CustomPaint(
              painter: BottomSheetCardPainter(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 54.h,
                    ), // Top padding to clear the top curve and dip
                    content,
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24.h,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating circular logo container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF131416),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(child: logo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mathematically perfect concentric curve parameters:
    final double logoRadius = 42.r;
    final double g = 8.r; // Concentric gap size (8 pixels)
    final double r1 = logoRadius + g; // Cutout radius (50.r)
    final double r2 = 12.r; // Shoulder radius
    final double flatY = 24.r; // Top flat line Y

    final double ys = flatY + r2;
    final double xSquare = (r1 + r2) * (r1 + r2) - ys * ys;
    final double xs = -math.sqrt(xSquare);

    final double xt = xs * r1 / (r1 + r2);
    final double yt = ys * r1 / (r1 + r2);

    final paint = Paint()
      ..color = const Color(0xFF0D0E10)
      ..style = PaintingStyle.fill;

    // Draw the main card body path (flat -> left shoulder -> concentric circular cutout -> right shoulder -> flat)
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, 40.r)
      ..quadraticBezierTo(0, flatY, 32.r, flatY)
      ..lineTo(w / 2 + xs, flatY)
      ..arcToPoint(
        Offset(w / 2 + xt, yt),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..arcToPoint(
        Offset(w / 2 - xt, yt),
        radius: Radius.circular(r1),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(w / 2 - xs, flatY),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..lineTo(w - 32.r, flatY)
      ..quadraticBezierTo(w, flatY, w, 40.r)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw the highlight outline on the top edge
    final borderPath = Path()
      ..moveTo(0, 40.r)
      ..quadraticBezierTo(0, flatY, 32.r, flatY)
      ..lineTo(w / 2 + xs, flatY)
      ..arcToPoint(
        Offset(w / 2 + xt, yt),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..arcToPoint(
        Offset(w / 2 - xt, yt),
        radius: Radius.circular(r1),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(w / 2 - xs, flatY),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..lineTo(w - 32.r, flatY)
      ..quadraticBezierTo(w, flatY, w, 40.r);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper function to show the custom dipped bottom sheet
Future<T?> showCustomDippedBottomSheet<T>({
  required BuildContext context,
  required Widget logo,
  required Widget content,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.6), // Blurred dim overlay
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, // support keyboard popups
        ),
        child: CustomDippedBottomSheet(logo: logo, content: content),
      );
    },
  );
}
