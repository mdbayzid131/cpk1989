import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/video_preview_widget.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with TickerProviderStateMixin {
  final SellController controller = Get.find<SellController>();
  bool _analysisFinished = false;

  // Bottom sheet slide-up animation
  late AnimationController _sheetController;
  late Animation<Offset> _sheetSlide;

  // Sparkle pulse animation
  late AnimationController _sparkleController;
  late Animation<double> _sparkleScale;

  // Step item fade-in animations
  late AnimationController _step1Controller;
  late AnimationController _step2Controller;
  late AnimationController _step3Controller;
  late Animation<double> _step1Fade;
  late Animation<double> _step2Fade;
  late Animation<double> _step3Fade;

  @override
  void initState() {
    super.initState();

    // Bottom sheet slide-up from below
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic),
        );

    // Sparkle twinkling
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _sparkleScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Step fade-in staggered
    _step1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _step2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _step3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _step1Fade = CurvedAnimation(
      parent: _step1Controller,
      curve: Curves.easeOut,
    );
    _step2Fade = CurvedAnimation(
      parent: _step2Controller,
      curve: Curves.easeOut,
    );
    _step3Fade = CurvedAnimation(
      parent: _step3Controller,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Animate sheet in
      _sheetController.forward();
      // Stagger steps in
      Future.delayed(
        const Duration(milliseconds: 300),
        () => _step1Controller.forward(),
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _step2Controller.forward(),
      );
      Future.delayed(
        const Duration(milliseconds: 700),
        () => _step3Controller.forward(),
      );

      // Start AI analysis logic
      controller.startAIAnalysis(() {
        if (mounted) {
          setState(() => _analysisFinished = true);
          final newItem = controller.addScannedItemToWardrobeSilently();
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              Get.offAndToNamed(AppRoutes.sellItemDetail, arguments: newItem);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _sparkleController.dispose();
    _step1Controller.dispose();
    _step2Controller.dispose();
    _step3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final activeIndex = controller.selectedItemIndex.value;
        final product = controller.galleryProducts[activeIndex];
        final priceFormatted =
            "AED ${product["price"].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
        final progress = controller.scanProgress.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background image/video
            _buildBackgroundPreview(product),

            // 2. Light blur overlay — keep background visible as in mockup
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withValues(alpha: 0.25)),
              ),
            ),

            // 3. Floating close button top-left
            Positioned(
              top: MediaQuery.of(context).padding.top + 14.h,
              left: 20.w,
              child: CustomGlassButton(
                size: 40.r,
                onTap: () => Get.back(),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),

            // 4. Animated Bottom Sheet
            SlideTransition(
              position: _sheetSlide,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141417),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 40.r,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _analysisFinished
                          ? _buildResultsSheet(product, priceFormatted)
                          : _buildScanningSheet(progress),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  } // ─── Scanning Sheet ────────────────────────────────────────────────────────

  Widget _buildScanningSheet(double progress) {
    return Padding(
      key: const ValueKey('scanning'),
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big circular ring with progress arc
          _buildLargeProgressRing(progress),
          SizedBox(height: 32.h),

          // Title
          Text(
            "Analysing brand ..",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            "Identifying brand, condition, and price",
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 32.h),

          // Step checklist card
          _buildChecklistCard(progress),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildLargeProgressRing(double progress) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return SizedBox(
          width: 240.r,
          height: 240.r,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost thin solid concentric circle
              Container(
                width: 230.r,
                height: 230.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
              ),

              // Intermediate glass/metallic textured circle
              Container(
                width: 195.r,
                height: 195.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF2C2D32), Color(0xFF151618)],
                    center: Alignment.center,
                    radius: 0.85,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      blurRadius: 24.r,
                      spreadRadius: 2.r,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),

              // Smooth Gold progress arc
              SizedBox(
                width: 175.r,
                height: 175.r,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return CustomPaint(painter: _GoldArcPainter(progress: val));
                  },
                ),
              ),

              // Inner solid dark circle
              Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F1012),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Closeté",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // Sparkle top-right (large) on the 230.r circle (radius = 115.r)
              // Angle = -30 degrees
              Positioned(
                left: (120.0 + 115.0 * math.cos(-30 * math.pi / 180)).r - 10.r,
                top: (120.0 + 115.0 * math.sin(-30 * math.pi / 180)).r - 10.r,
                child: Transform.scale(
                  scale: _sparkleScale.value,
                  child: const SparkleWidget(size: 20, color: Colors.white),
                ),
              ),

              // Sparkle bottom-left (small) on the 230.r circle (radius = 115.r)
              // Angle = 160 degrees
              Positioned(
                left: (120.0 + 115.0 * math.cos(160 * math.pi / 180)).r - 7.r,
                top: (120.0 + 115.0 * math.sin(160 * math.pi / 180)).r - 7.r,
                child: Transform.scale(
                  scale: 1.0 - (_sparkleScale.value * 0.3),
                  child: SparkleWidget(
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistCard(double progress) {
    final bool step1Done = progress >= 0.35;
    final bool step1Active = progress < 0.35;
    final bool step2Done = progress >= 0.70;
    final bool step2Active = progress >= 0.35 && progress < 0.70;
    final bool step3Done = progress >= 1.0;
    final bool step3Active = progress >= 0.70 && progress < 1.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF161719),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _step1Fade,
            child: _buildStepRow(
              label: "Brand identified",
              isCompleted: step1Done,
              isActive: step1Active,
              isLast: false,
            ),
          ),
          FadeTransition(
            opacity: _step2Fade,
            child: _buildStepRow(
              label: "Assessing condition",
              isCompleted: step2Done,
              isActive: step2Active,
              isLast: false,
            ),
          ),
          FadeTransition(
            opacity: _step3Fade,
            child: _buildStepRow(
              label: "Estimating market price",
              isCompleted: step3Done,
              isActive: step3Active,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String label,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final Color activeGold = const Color(0xFFE2B744);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left indicator column
        Column(
          children: [
            // Bullet / check
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isCompleted
                  ? Container(
                      key: const ValueKey('completed'),
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: activeGold, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: activeGold,
                          size: 13.sp,
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('pending'),
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: isActive ? 0.6 : 0.25,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),

            // Vertical connector line
            if (!isLast)
              _buildConnectorLine(
                isSolid: isCompleted,
                color: isCompleted
                    ? activeGold
                    : Colors.white.withValues(alpha: 0.12),
              ),
          ],
        ),
        SizedBox(width: 16.w),
        // Label — aligned vertically with bullet center
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              fontWeight: isCompleted || isActive
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: isCompleted
                  ? activeGold
                  : isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine({required bool isSolid, required Color color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SizedBox(
        height: 24.h,
        width: 1.5.w,
        child: AnimatedCrossFade(
          firstChild: Container(width: 1.5.w, color: color),
          secondChild: SizedBox(
            width: 1.5.w,
            height: 24.h,
            child: CustomPaint(
              painter: _DashedLinePainter(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          crossFadeState: isSolid
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  // ─── Results Sheet ─────────────────────────────────────────────────────────

  Widget _buildResultsSheet(
    Map<String, dynamic> product,
    String priceFormatted,
  ) {
    final goldGradient = const LinearGradient(
      colors: [
        Color(0xFFAF7413),
        Color(0xFFC98C28),
        Color(0xFFE2B744),
        Color(0xFFFFED81),
        Color(0xFFE1C24E),
        Color(0xFFA06008),
      ],
      stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
      key: const ValueKey('results'),
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heading row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AI VALUATION REPORT",
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE2B744),
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF30D158).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF30D158),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: const Color(0xFF30D158),
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "AUTHENTIC: ${product["authScore"]}",
                      style: GoogleFonts.manrope(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF30D158),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 24.h),
          _buildResultRow("Brand detected", product["brand"]),
          _buildResultRow("Model name", controller.itemNameInput.value),
          _buildResultRow("Serial / Date code", product["serialNumber"]),
          _buildResultRow(
            "Verified condition",
            controller.conditionInput.value,
          ),
          _buildResultRow(
            "Estimated resale value",
            priceFormatted,
            highlight: true,
          ),
          SizedBox(height: 24.h),

          // Confirm & Publish button
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC98C28).withValues(alpha: 0.35),
                  blurRadius: 16.r,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.addScannedItemToWardrobe(),
                borderRadius: BorderRadius.circular(28.r),
                child: Center(
                  child: Text(
                    "CONFIRM & PUBLISH LISTING",
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: highlight ? 15.sp : 14.sp,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
              color: highlight ? const Color(0xFFE2B744) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Background preview ────────────────────────────────────────────────────

  Widget _buildBackgroundPreview(Map<String, dynamic> product) {
    final path = controller.rxCapturedPath.value;
    final isVideo =
        path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.3gp');
    if (path.isNotEmpty) {
      return Positioned.fill(
        child: isVideo
            ? VideoPreviewWidget(videoPath: path, muted: true)
            : Image.file(File(path), fit: BoxFit.cover),
      );
    }
    return Positioned.fill(
      child: Image.network(product["imageUrl"], fit: BoxFit.cover),
    );
  }
}

// ─── Sparkle Widgets & Painters ──────────────────────────────────────────────

class SparkleWidget extends StatelessWidget {
  final double size;
  final Color color;

  const SparkleWidget({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final path = Path();
    path.moveTo(cx, cy - r); // Top
    path.quadraticBezierTo(cx, cy, cx + r, cy); // Curve to Right
    path.quadraticBezierTo(cx, cy, cx, cy + r); // Curve to Bottom
    path.quadraticBezierTo(cx, cy, cx - r, cy); // Curve to Left
    path.quadraticBezierTo(cx, cy, cx, cy - r); // Curve back to Top
    path.close();

    // Draw a subtle glow under the sparkle
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx, cy), r * 0.5, glowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

/// Gold arc that sweeps clockwise from the top (-90°)
class _GoldArcPainter extends CustomPainter {
  final double progress;
  _GoldArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;

    // Track ring (faint)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 2, trackPaint);

    if (progress <= 0) return;

    // Gold gradient arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          Color(0xFFAF7413),
          Color(0xFFE2B744),
          Color(0xFFFFED81),
          Color(0xFFC98C28),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );

    // Glowing dot at the arc tip
    if (progress > 0.01) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final tipX = center.dx + (radius - 2) * math.cos(angle);
      final tipY = center.dy + (radius - 2) * math.sin(angle);

      final dotGlow = Paint()
        ..color = const Color(0xFFE2B744).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(tipX, tipY), 8, dotGlow);

      final dotPaint = Paint()..color = const Color(0xFFFFED81);
      canvas.drawCircle(Offset(tipX, tipY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GoldArcPainter old) => old.progress != progress;
}

/// Dashed vertical line connector between steps
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const gapHeight = 3.0;
    double startY = 0;
    final cx = size.width / 2;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(cx, startY),
        Offset(cx, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
