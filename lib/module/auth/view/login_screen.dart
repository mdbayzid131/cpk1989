import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/auth/controller/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double logoCenterY =
        statusBarHeight + 50.h + 20.h; // logo is at top: 50.h with ~40.h height

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Stack(
        children: [
          // 1. Static sunburst background centered exactly on the logo
          Positioned.fill(
            child: CustomPaint(
              painter: LoginSunburstPainter(
                logoCenter: Offset(screenWidth / 2, logoCenterY),
                rayColor: const Color(0xFFE2B744).withValues(alpha: 0.30),
                rayCount: 48,
              ),
            ),
          ),

          // 2. Radial gradient overlay (spotlight centered on the logo)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    0.0,
                    (logoCenterY / (screenHeight / 2)) - 1.0,
                  ),
                  radius: 0.80,
                  colors: [
                    const Color(0xFF0F1012).withValues(alpha: 0.0),
                    const Color(0xFF0F1012).withValues(alpha: 0.0),
                    const Color(0xFF0F1012).withValues(alpha: 0.75),
                    const Color(0xFF0F1012),
                  ],
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. Central logo at the top (moved down a bit)
          Positioned(
            top: statusBarHeight + 50.h,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/closet_logo.svg',
                width: 140.w,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 4. Dipped card containing login/signup form
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: screenHeight * 0.24, // Card starts at 24% of screen height
            child: CustomPaint(
              painter: LoginCardPainter(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top spacing to clear the dipped top edge curve
                      SizedBox(height: 64.h),

                      // Card Titles
                      Center(
                        child: Text(
                          "Create your account",
                          style: GoogleFonts.prata(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: Text(
                          "Discover and sell luxury, effortlessly",
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                      SizedBox(height: 36.h),

                      // Text Input Fields
                      _buildTextField(
                        controller: controller.firstNameController,
                        hintText: "First name",
                        prefixIcon: Icons.person_outline_rounded,
                        validator: controller.validateFirstName,
                      ),
                      SizedBox(height: 14.h),

                      _buildTextField(
                        controller: controller.lastNameController,
                        hintText: "Last name",
                        prefixIcon: Icons.person_outline_rounded,
                        validator: controller.validateLastName,
                      ),
                      SizedBox(height: 14.h),

                      _buildTextField(
                        controller: controller.emailController,
                        hintText: "Email",
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                      ),

                      const Spacer(),

                      // Golden gradient Continue Button
                      Obx(() {
                        final isLoading = controller.rxIsLoading.value;
                        return Container(
                          height: 52.h,
                          margin: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).padding.bottom + 20.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26.r),
                            gradient: isLoading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFAF7413),
                                      Color(0xFFC98C28),
                                      Color(0xFFE2B744),
                                      Color(0xFFFFED81),
                                      Color(0xFFE1C24E),
                                      Color(0xFFA06008),
                                    ],
                                    stops: [
                                      0.0477,
                                      0.1933,
                                      0.3893,
                                      0.5054,
                                      0.6210,
                                      0.9074,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: isLoading ? const Color(0xFF1E2022) : null,
                            boxShadow: isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFC98C28,
                                      ).withValues(alpha: 0.25),
                                      blurRadius: 15.r,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => controller.continueAuth(context),
                              borderRadius: BorderRadius.circular(26.r),
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        height: 20.w,
                                        width: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFE2B744),
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Continue",
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.black,
                                            size: 18.sp,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white38,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Icon(prefixIcon, color: Colors.white54, size: 20.sp),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w),
        filled: true,
        fillColor: const Color(0xFF1B1C1E),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE2B744), width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}

class LoginCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mathematically perfect concentric curve parameters:
    final double logoRadius = 42.r;
    final double g = 8.r; // Concentric gap size (8 pixels)
    final double r1 = logoRadius + g; // Cutout radius (50.r)
    final double r2 = 12.r; // Shoulder radius
    final double flatY = 24.r; // Top flat line Y

    final double ys = flatY + r2;
    final double xSquare = (r1 + r2) * (r1 + r2) - ys * ys;
    final double xs = -math.sqrt(xSquare);

    final double xt = xs * r1 / (r1 + r2);
    final double yt = ys * r1 / (r1 + r2);

    final paint = Paint()
      ..color = const Color(0xFF0D0E10)
      ..style = PaintingStyle.fill;

    // Draw the main card body path (flat -> left shoulder -> concentric circular cutout -> right shoulder -> flat)
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, 40.r)
      ..quadraticBezierTo(0, flatY, 32.r, flatY)
      ..lineTo(w / 2 + xs, flatY)
      ..arcToPoint(
        Offset(w / 2 + xt, yt),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..arcToPoint(
        Offset(w / 2 - xt, yt),
        radius: Radius.circular(r1),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(w / 2 - xs, flatY),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..lineTo(w - 32.r, flatY)
      ..quadraticBezierTo(w, flatY, w, 40.r)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw the highlight outline on the top edge
    final borderPath = Path()
      ..moveTo(0, 40.r)
      ..quadraticBezierTo(0, flatY, 32.r, flatY)
      ..lineTo(w / 2 + xs, flatY)
      ..arcToPoint(
        Offset(w / 2 + xt, yt),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..arcToPoint(
        Offset(w / 2 - xt, yt),
        radius: Radius.circular(r1),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(w / 2 - xs, flatY),
        radius: Radius.circular(r2),
        clockwise: true,
      )
      ..lineTo(w - 32.r, flatY)
      ..quadraticBezierTo(w, flatY, w, 40.r);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginSunburstPainter extends CustomPainter {
  final Offset logoCenter;
  final Color rayColor;
  final int rayCount;

  LoginSunburstPainter({
    required this.logoCenter,
    required this.rayColor,
    this.rayCount = 48,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = logoCenter;
    final maxRadius = size.longestSide * 1.2;

    // Decouple the gradient radius from container size to keep the rays properly visible
    final double gradientRadius = 852.0; // Same scale as on the splash screen
    final rect = Rect.fromCircle(center: center, radius: gradientRadius);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          rayColor.withValues(alpha: 0.0),
          rayColor.withValues(alpha: 0.01),
          rayColor,
          rayColor.withValues(alpha: 0.01),
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
  bool shouldRepaint(covariant LoginSunburstPainter oldDelegate) {
    return oldDelegate.logoCenter != logoCenter ||
        oldDelegate.rayColor != rayColor ||
        oldDelegate.rayCount != rayCount;
  }
}
