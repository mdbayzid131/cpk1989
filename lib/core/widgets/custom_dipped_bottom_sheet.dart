import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable custom premium bottom sheet featuring:
/// - Background drawn dynamically via CustomPainter using precise vector Bezier curves
/// - Height auto-adjusts to wrap the content and bottom padding dynamically
/// - Floating circular logo centered on the custom-drawn dip (optional)
/// - Ambient golden flashlight rays, stars, and logo container background from SVG
class CustomDippedBottomSheet extends StatelessWidget {
  final Widget? logo;
  final Widget content;
  final double? screenBottomPadding;

  const CustomDippedBottomSheet({
    super.key,
    this.logo,
    required this.content,
    this.screenBottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // SVG coordinate space is based on width 422.729
    final double scale = screenWidth / 422.729;

    // We only calculate the bottom padding when the keyboard is closed.
    // When the keyboard is open, viewInsets.bottom handles the spacing,
    // so we only need a clean minimal bottom padding.
    final double systemBottomPadding =
        screenBottomPadding ?? MediaQuery.of(context).padding.bottom;
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 16.h
        : (systemBottomPadding > 0 ? systemBottomPadding : 20.h) + 24.h;

    // Flashlight beam with container geometry based on card width 393.0 inside SVG
    final double scaleFlashlight = screenWidth / 393.0;
    final double flashlightWidth = 403.0 * scaleFlashlight;
    final double flashlightHeight = 290.0 * scaleFlashlight;
    final double flashlightTop =
        (54.0 * scale) - (117.0 * scaleFlashlight) - 12;

    // Center coordinates for the floating logo (aligned with circle center)
    final double logoCenterX = screenWidth / 2;
    final double logoCenterY = (54.0 * scale) - 12;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 0. Ambient golden flashlight rays, stars, and container background SVG
        Positioned(
          top: flashlightTop,
          left: 0,
          width: flashlightWidth,
          height: flashlightHeight,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: SvgPicture.asset(
              'assets/icons/flash light with container .svg',
              width: flashlightWidth,
              height: flashlightHeight,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
            ),
          ),
        ),

        // 1. Main card body with content
        CustomPaint(
          painter: DippedBottomSheetPainter(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Spacer to push content below the logo and the dip (bottom of dip is at y=180, shifted: 117)
              SizedBox(height: 117.0 * scale + 8.h),

              // The content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: content,
              ),

              // Bottom padding for keyboard or safe area
              SizedBox(height: bottomPadding),
            ],
          ),
        ),

        // 2. Floating logo positioned exactly over the CustomPaint ellipse (if provided)
        if (logo != null)
          Positioned(
            top: logoCenterY,
            left: logoCenterX,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: logo!,
            ),
          ),
      ],
    );
  }
}

class DippedBottomSheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final double scale = w / 422.729;

    double sx(double x) => x * scale;
    double sy(double y) => (y - 63.0) * scale;

    // 1. Paint the main card background
    final cardPaint = Paint()
      ..color = const Color(0xFF0F1012)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, sy(153.0))
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, sy(153.0))
      ..cubicTo(w, sy(136.432), sx(409.297), sy(123.0), sx(392.729), sy(123.0))
      ..lineTo(sx(303.586), sy(123.0))
      ..cubicTo(
        sx(289.218),
        sy(123.0),
        sx(277.715),
        sy(134.447),
        sx(270.502),
        sy(146.874),
      )
      ..cubicTo(
        sx(259.055),
        sy(166.598),
        sx(236.624),
        sy(180.0),
        sx(210.826),
        sy(180.0),
      )
      ..cubicTo(
        sx(185.028),
        sy(180.0),
        sx(162.597),
        sy(166.598),
        sx(151.15),
        sy(146.874),
      )
      ..cubicTo(
        sx(143.938),
        sy(134.447),
        sx(132.434),
        sy(123.0),
        sx(118.067),
        sy(123.0),
      )
      ..lineTo(sx(30.0), sy(123.0))
      ..cubicTo(sx(13.4315), sy(123.0), 0, sy(136.431), 0, sy(153.0))
      ..close();

    canvas.drawPath(path, cardPaint);

    // 2. Paint the gradient border highlight on card top curves
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33FFFFFF), // rgba(255, 255, 255, 0.2)
          Color(0x00FFFFFF), // rgba(255, 255, 255, 0)
        ],
        stops: [0.0, 0.8673],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final borderPath = Path()
      ..moveTo(0, sy(153.0))
      ..cubicTo(0, sy(136.431), sx(13.4315), sy(123.0), sx(30.0), sy(123.0))
      ..lineTo(sx(118.067), sy(123.0))
      ..cubicTo(
        sx(132.434),
        sy(123.0),
        sx(143.938),
        sy(134.447),
        sx(151.15),
        sy(146.874),
      )
      ..cubicTo(
        sx(162.597),
        sy(166.598),
        sx(185.028),
        sy(180.0),
        sx(210.826),
        sy(180.0),
      )
      ..cubicTo(
        sx(236.624),
        sy(180.0),
        sx(259.055),
        sy(166.598),
        sx(270.502),
        sy(146.874),
      )
      ..cubicTo(
        sx(277.715),
        sy(134.447),
        sx(289.218),
        sy(123.0),
        sx(303.586),
        sy(123.0),
      )
      ..lineTo(sx(392.729), sy(123.0))
      ..cubicTo(sx(409.297), sy(123.0), w, sy(136.432), w, sy(153.0));

    canvas.drawPath(borderPath, borderPaint);

    // 3. Paint the custom golden blur glow centered on the logo circle pocket
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFE2B744).withValues(alpha: 0.4),
              const Color(0xFFE2B744).withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w / 2, sy(117.0)),
              radius: 80.0 * scale,
            ),
          );

    canvas.drawCircle(Offset(w / 2, sy(117.0)), 80.0 * scale, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper function to show the custom dipped bottom sheet
Future<T?> showCustomDippedBottomSheet<T>({
  required BuildContext context,
  Widget? logo,
  required Widget content,
  bool isDismissible = true,
}) {
  final double screenBottomPadding = MediaQuery.of(context).padding.bottom;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (sheetContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: CustomDippedBottomSheet(
            logo: logo,
            content: content,
            screenBottomPadding: screenBottomPadding,
          ),
        ),
      );
    },
  );
}
