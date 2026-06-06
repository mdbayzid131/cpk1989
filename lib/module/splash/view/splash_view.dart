import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/splash/controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Stack(
        children: [
          // 1. Rotating sunburst background
          const Positioned.fill(
            child: RotatingSunburst(),
          ),

          // 2. Radial gradient overlay to fade the rays and add central glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.12), // Beautiful gold glow behind logo
                    const Color(0xFF0F1012).withValues(alpha: 0.5),
                    const Color(0xFF0F1012).withValues(alpha: 0.95),
                    const Color(0xFF0F1012), // Absolute black/gray at screen edges
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
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
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFF0CA), // Extra bright highlight gold
                    Color(0xFFF9E49B), // Light gold
                    Color(0xFFD4AF37), // Pure gold
                    Color(0xFFB38915), // Mid bronze/gold
                    Color(0xFFE6C362), // Bright gold accent
                    Color(0xFF8A6605), // Dark shadow gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  'Closeté',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // crucial for shader mask to display colors properly
                    letterSpacing: 1.5,
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

/// A CustomPainter that draws radiating sunburst rays.
class SunburstPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  SunburstPainter({
    required this.rayColor,
    this.rayCount = 48,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 1.2; // exceed the screen edges to be safe
    final paint = Paint()
      ..color = rayColor
      ..style = PaintingStyle.fill;

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
    return oldDelegate.rayColor != oldDelegate.rayColor || oldDelegate.rayCount != rayCount;
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
          rayColor: const Color(0xFFD4AF37).withValues(alpha: 0.04), // soft bronze/gold rays
          rayCount: 48,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
