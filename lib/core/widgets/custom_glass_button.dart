import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Painter that draws a mathematically precise, crisp gradient border around a circle.
class CircleGradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double strokeWidth;

  CircleGradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    // Deflate by half the stroke width to ensure the border stays exactly within container bounds
    canvas.drawOval(rect.deflate(strokeWidth / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ===================== CUSTOM GLASS BUTTON =====================
/// Reusable glassmorphic circular button with:
/// - Real-time GPU-accelerated liquid glass shader (via `liquid_glass_renderer`)
/// - Figma specs: 50px x 50px diameter
/// - 12px internal padding
/// - Translucent fill (#FFFFFF at 8% opacity)
/// - Crisp, 1px top-left border gradient highlight custom-painted on top
class CustomGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;

  const CustomGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 50.0,
    this.blurSigma = 15.0, // Glass frosted blur strength
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Top-left highlight gradient matching Figma spec reflections
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(
          alpha: 0.65,
        ), // Brighter top-left highlight for glass refraction
        Colors.white.withValues(
          alpha: 0.0,
        ), // Complete fade out on bottom-right
      ],
      stops: const [0.0, 0.7],
    );

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircleGradientBorderPainter(
          gradient: borderGradient,
          strokeWidth: 1.0,
        ),
        child: LiquidGlass.withOwnLayer(
          settings: LiquidGlassSettings(
            thickness: 10.0, // refraction intensity
            blur: blurSigma, // blur intensity
            glassColor: Colors.white.withValues(
              alpha: 0.08,
            ), // Figma: #FFFFFF at 8% opacity
            lightIntensity: 1.0,
            lightAngle:
                0.25 *
                math.pi, // Diagonal light source (top-left to bottom-right highlight)
          ),
          shape: LiquidOval(),
          glassContainsChild:
              false, // child (e.g. icon) rendered normally on top
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: padding ?? EdgeInsets.all(size > 40.0 ? 12.0 : 6.0),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
