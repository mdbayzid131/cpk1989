import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessingOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const ProcessingOverlay({super.key, required this.onComplete});

  @override
  State<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<ProcessingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // End after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom spinning gold arc loader
          RotationTransition(
            turns: _rotationController,
            child: SizedBox(
              width: 80.r,
              height: 80.r,
              child: CustomPaint(
                painter: _RotatingLoaderPainter(),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Processing..",
            style: GoogleFonts.dmSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingLoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.r
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 2.r, trackPaint);

    // Gold gradient arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.r
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: 3.14 * 2,
        colors: [
          Color(0xFFAF7413),
          Color(0xFFE2B744),
          Color(0xFFFFED81),
          Color(0xFFE2B744),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2.r),
      0.0,
      3.14 * 1.5, // 3/4 circular sweep
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Global static helper to show processing overlay
void showProcessingOverlay(BuildContext context, VoidCallback onComplete) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return ProcessingOverlay(
        onComplete: () {
          Navigator.pop(context); // Pop overlay dialog
          onComplete();
        },
      );
    },
  );
}
