import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with TickerProviderStateMixin {
  late final AnimationController _scannerController;
  late final AnimationController _focusController;
  late final Animation<double> _focusScale;

  @override
  void initState() {
    super.initState();
    // Repeating scanner controller (goes up and down)
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Focus brackets pulse controller
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _focusScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70.h),

        ///<================= HEADER TEXT =========================>///
        Text(
          'Sell in',
          style: GoogleFonts.prata(
            fontSize: 38.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFAF7413),
              Color(0xFFC98C28),
              Color(0xFFE2B744),
              Color(0xFFFFED81),
              Color(0xFFE1C24E),
              Color(0xFFA06008),
            ],
            stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            '60 Seconds',
            style: GoogleFonts.prata(
              fontSize: 38.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Small gold horizontal accent line
        Container(width: 32.w, height: 2.h, color: const Color(0xFFC98C28)),
        const Spacer(),

        ///<================= CAMERA PREVIEW WIDGET =========================>///
        Container(
          width: double.infinity,
          height: 380.h,
          color: Colors.transparent,
          child: Stack(
            children: [
              // 1. Closet Image Background
              Positioned.fill(
                child: Image.asset(
                  'assets/images/closet_scan.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2. Vertical vignette overlay (black at top and bottom, clear/transparent in the middle)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F1012),
                        const Color(0xFF0F1012).withValues(alpha: 0.0),
                        const Color(0xFF0F1012).withValues(alpha: 0.0),
                        const Color(0xFF0F1012),
                      ],
                      stops: const [0.0, 0.22, 0.70, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Viewfinder focus brackets (pulsing scale)
              Center(
                child: ScaleTransition(
                  scale: _focusScale,
                  child: SizedBox(
                    width: 320.w,
                    height: 300.w,
                    child: CustomPaint(painter: FocusBracketsPainter()),
                  ),
                ),
              ),

              // 4. Scanner laser line (animating top to bottom inside brackets)
              Center(
                child: SizedBox(
                  width: 300.w,
                  height: 280.w,
                  child: AnimatedBuilder(
                    animation: _scannerController,
                    builder: (context, child) {
                      final yOffset = _scannerController.value * 280.w;
                      return Stack(
                        children: [
                          Positioned(
                            top: yOffset,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(
                                      0xFFFFED81,
                                    ).withValues(alpha: 0.8),
                                    const Color(0xFFE2B744),
                                    const Color(
                                      0xFFFFED81,
                                    ).withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE2B744,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 5. Camera UI bottom controls (Flash, Shutter, Gallery)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Flash Off Icon
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: Icon(
                        Icons.flash_off_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 18.w,
                      ),
                    ),

                    // Camera Shutter Button
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE0E0E0),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.3),
                          width: 5.w,
                        ),
                      ),
                    ),

                    // Gallery Icon
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 18.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        ///<================= DESCRIPTION TEXT =========================>///
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Record. Upload. We handle the rest,\nwhile you get paid.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class FocusBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 24.w;
    final double radius = 16.r; // Rounded corners for brackets

    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - radius,
        )
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
