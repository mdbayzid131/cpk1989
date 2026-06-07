import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/module/splash/controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0A0A0C,
      ), // Dark premium charcoal background
      body: Stack(
        children: [
          // 1. Rotating sunburst background
          const Positioned.fill(child: RotatingSunburst()),

          // 2. Radial gradient overlay to fade the rays and add central glow (spotlight effect)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.80,
                  colors: [
                    const Color(0xFF0A0A0C).withValues(
                      alpha: 0.0,
                    ), // No darkness in the center (completely clear)
                    const Color(0xFF0A0A0C).withValues(
                      alpha: 0.0,
                    ), // Keep the logo area completely clear
                    const Color(0xFF0A0A0C).withValues(
                      alpha: 0.75,
                    ), // Smoothly transitions to darkness
                    const Color(
                      0xFF0A0A0C,
                    ), // Pitch black edges (inverse vignette overlay)
                  ],
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. Central animating logo
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeIn,
                    builder: (context, opacity, child) {
                      return Opacity(opacity: opacity, child: child);
                    },
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/icons/closet_logo.svg',
                width: 180.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A CustomPainter that draws radiating sunburst rays.
class SunburstPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  SunburstPainter({required this.rayColor, this.rayCount = 48});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        size.longestSide * 1.2; // exceed the screen edges to be safe
    final rect = Rect.fromCircle(center: center, radius: maxRadius);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          rayColor.withValues(
            alpha: 0.0,
          ), // Completely transparent in the center (behind logo)
          rayColor.withValues(alpha: 0.01), // Keep the center clear of rays
          rayColor, // Max brightness in the mid-range
          rayColor.withValues(alpha: 0.01), // Fades out towards the edges
        ],
        stops: const [0.0, 0.08, 0.22, 0.6],
      ).createShader(rect);

    final angleStep = (2 * math.pi) / rayCount;
    final path = Path();

    for (int i = 0; i < rayCount; i += 2) {
      final startAngle = i * angleStep;
      final endAngle = (i + 1) * angleStep;

      path.reset();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + maxRadius * math.cos(startAngle),
        center.dy + maxRadius * math.sin(startAngle),
      );
      path.lineTo(
        center.dx + maxRadius * math.cos(endAngle),
        center.dy + maxRadius * math.sin(endAngle),
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SunburstPainter oldDelegate) {
    return oldDelegate.rayColor != oldDelegate.rayColor ||
        oldDelegate.rayCount != rayCount;
  }
}

/// A stateful wrapper that slowly rotates the sunburst background.
class RotatingSunburst extends StatefulWidget {
  const RotatingSunburst({super.key});

  @override
  State<RotatingSunburst> createState() => _RotatingSunburstState();
}

class _RotatingSunburstState extends State<RotatingSunburst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // slow, premium rotation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        painter: SunburstPainter(
          rayColor: const Color(
            0xFFE2B744,
          ).withValues(alpha: 0.30), // warmer, richer gold rays
          rayCount: 48,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
