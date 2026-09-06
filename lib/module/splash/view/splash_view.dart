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
        0xFF0F1012,
      ), // Dark premium charcoal background
      body: Stack(
        children: [
          // 1. Rotating SVG background from Figma
          const Positioned.fill(child: RotatingBackground()),

          // 2. Radial gradient overlay: keeps the center dark/clean for the logo, lets the golden rays fan out in the mid-ring, and darkens the outer edges
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.90,
                  colors: [
                    const Color(0xFF0F1012).withValues(
                      alpha: 0.55,
                    ), // Soft balanced darkness in center
                    const Color(
                      0xFF0F1012,
                    ).withValues(alpha: 0.20), // Smooth transition
                    Colors.transparent, // Clean space for prominent rays
                    const Color(
                      0xFF0F1012,
                    ).withValues(alpha: 0.85), // Fades to dark at the edges
                  ],
                  stops: const [0.0, 0.22, 0.50, 1.0],
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
                width: 140.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A stateful wrapper that slowly rotates the background SVG.
class RotatingBackground extends StatefulWidget {
  const RotatingBackground({super.key});

  @override
  State<RotatingBackground> createState() => _RotatingBackgroundState();
}

class _RotatingBackgroundState extends State<RotatingBackground>
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
      child: Transform.scale(
        scale:
            1.5, // scale up slightly so screen corners aren't exposed as it rotates
        child: SvgPicture.asset(
          'assets/icons/splash_bg.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
