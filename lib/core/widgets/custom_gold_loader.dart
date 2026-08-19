import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A custom luxury golden circular progress loader using the exact 
/// GoldRotatingLoaderPainter from processing_overlay.dart matching Closeté design.
class CustomGoldLoader extends StatefulWidget {
  final double? size;
  final double? strokeWidth;
  final Color? color;

  const CustomGoldLoader({
    super.key,
    this.size,
    this.strokeWidth,
    this.color,
  });

  @override
  State<CustomGoldLoader> createState() => _CustomGoldLoaderState();
}

class _CustomGoldLoaderState extends State<CustomGoldLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 36.r;
    final strokeWidth = widget.strokeWidth ?? (size > 50 ? 5.r : 3.r);

    return RotationTransition(
      turns: _rotationController,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: GoldRotatingLoaderPainter(
            strokeWidth: strokeWidth,
            goldColor: widget.color,
          ),
        ),
      ),
    );
  }
}

class GoldRotatingLoaderPainter extends CustomPainter {
  final double? strokeWidth;
  final Color? goldColor;

  GoldRotatingLoaderPainter({
    this.strokeWidth,
    this.goldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final stroke = strokeWidth ?? 5.r;
    final strokeOffset = stroke / 2;

    // Track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      center,
      math.max(0, radius - strokeOffset),
      trackPaint,
    );

    // Gold gradient arc (exact processing_overlay.dart painter)
    final mainGold = goldColor ?? const Color(0xFFE2B744);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 3.14 * 2,
        colors: [
          const Color(0xFFAF7413),
          mainGold,
          const Color(0xFFFFED81),
          mainGold,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: math.max(0, radius - strokeOffset)),
      0.0,
      3.14 * 1.5, // 3/4 circular sweep
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
