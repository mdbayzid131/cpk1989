import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final SellController controller = Get.find<SellController>();
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start AI analysis logic
      controller.startAIAnalysis(() {
        if (mounted) {
          final newItem = controller.addScannedItemToWardrobeSilently();
          Get.offAndToNamed(AppRoutes.sellItemDetail, arguments: newItem);
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final activeIndex = controller.selectedItemIndex.value;
        final product = controller.galleryProducts[activeIndex];

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background image
            _buildBackgroundPreview(product),

            // 2. Dark Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.black.withValues(alpha: 0.55)),
              ),
            ),

            // 3. Centered Loader & Processing text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationController,
                    child: SizedBox(
                      width: 60.r,
                      height: 60.r,
                      child: CustomPaint(
                        painter: _GradientArcPainter(
                          colors: const [
                            Color(0xffAE4E00),
                            Color(0xffB47E11),
                            Color(0xffEFD983),
                            Color(0xffFEF1A2),
                            Color(0xffEFD983),
                            Color(0xffBC881B),
                            Color(0xffA54E07),
                          ],
                          stops: const [
                            0.0,
                            0.25,
                            0.3926,
                            0.4441,
                            0.492,
                            0.75,
                            1.0,
                          ],
                          strokeWidth: 4.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Obx(() {
                    final progress = controller.scanProgress.value;
                    String statusText = "Analysing brand";
                    if (progress >= 0.66) {
                      statusText = "Estimating Market price";
                    } else if (progress >= 0.33) {
                      statusText = "Assessing condition";
                    }

                    return AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        final dotCount = (_rotationController.value * 4)
                            .floor();
                        final dots = "." * dotCount;
                        return Text(
                          "$statusText$dots",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackgroundPreview(Map<String, dynamic> product) {
    final path = controller.rxCapturedPath.value;
    if (path.isNotEmpty) {
      return Positioned.fill(child: Image.file(File(path), fit: BoxFit.cover));
    }
    return Positioned.fill(
      child: Image.network(product["imageUrl"], fit: BoxFit.cover),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> stops;
  final double strokeWidth;

  _GradientArcPainter({
    required this.colors,
    required this.stops,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;

    // 1. Draw inactive track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // 2. Draw active gold gradient arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        stops: stops,
        startAngle: 0.0,
        endAngle: 1.35 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      1.35 * math.pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
