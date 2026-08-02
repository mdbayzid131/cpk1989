import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/auth/controller/auth_controller.dart';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_dipped_bottom_sheet.dart';
import 'package:cpk1989/module/auth/view/email_verification_bottom_sheet.dart';
import 'package:cpk1989/core/utils/validators.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Moved logo further down to be "more in the middle"
    final double logoTop = 130.h;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              // 1. Background sunburst rays from Figma SVG
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  'assets/icons/Group.svg',
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),

              // 3. Central logo at the top
              Positioned(
                top: logoTop,
                left: 0,
                right: 0,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/closet_logo.svg',
                    width: 110.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 4. Dipped card containing login/signup form
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 199.h, // Card starts at 199.h
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
                              "Login or create your account",
                              style: TextStyle(
                                fontFamily: 'Schnyder L',
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.primaryText,
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
                                color: AppTheme.gray,
                              ),
                            ),
                          ),
                          SizedBox(height: 36.h),

                          // Text Input Fields
                          _buildTextField(
                            controller: controller.firstNameController,
                            hintText: "First name",
                            prefixIconPath: "assets/icons/person.svg",
                            validator: (value) => controller.lastNameController.text.trim().isNotEmpty
                                ? Validators.required(value, message: "First name is required for registration")
                                : null,
                          ),
                          SizedBox(height: 10.h),

                          _buildTextField(
                            controller: controller.lastNameController,
                            hintText: "Mendes",
                            prefixIconPath: "assets/icons/person.svg",
                            validator: (value) => controller.firstNameController.text.trim().isNotEmpty
                                ? Validators.required(value, message: "Last name is required for registration")
                                : null,
                          ),
                          SizedBox(height: 10.h),

                          _buildTextField(
                            controller: controller.emailController,
                            hintText: "Email",
                            prefixIconPath: "assets/icons/mail.svg",
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),

                          const Spacer(),

                          // Golden gradient Continue Button
                          Obx(() {
                            final isLoading = controller.rxIsLoading.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).padding.bottom +
                                    20.h,
                              ),
                              child: CustomGoldButton(
                                text: "Continue",
                                isLoading: isLoading,
                                onTap: () async {
                                  final success = await controller
                                      .prepareAuth();
                                  if (success && context.mounted) {
                                    controller.clearOtpFields();
                                    controller.startOtpTimer();

                                    showCustomDippedBottomSheet(
                                      context: context,
                                      logo: Image.asset(
                                        'assets/icons/message_svg.png',
                                        width: 75.w,
                                        height: 75.w,
                                        fit: BoxFit.contain,
                                      ),
                                      content:
                                          const EmailVerificationBottomSheetContent(),
                                    ).then((_) {
                                      controller.stopOtpTimer();
                                    });
                                  }
                                },
                                suffix: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.black,
                                  size: 18.sp,
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String prefixIconPath,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              border: Border.all(
                color: hasFocus
                    ? const Color(0xFFE2B744)
                    : Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            child: Center(
              child: TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.grayTerritory,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 15.w, right: 10.w),
                    child: SvgPicture.asset(
                      prefixIconPath,
                      colorFilter: const ColorFilter.mode(
                        Colors.white54,
                        BlendMode.srcIn,
                      ),
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 40.w),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.only(
                    top: 10.h,
                    bottom: 10.h,
                    right: 10.w,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Perfect fluid Bezier dip parameters matching Figma smooth vectors
    final double flatY = 24.r; // Top flat line Y
    final double dipWidth = 156.w; // Total width of the dip
    final double dipDepth = 26.r; // Depth of the dip below flatY
    final double xs = -dipWidth / 2;

    // Control point offsets for elegant "squircle" curve transitions
    final double cp1X = 36.w; // Smooths the top shoulder
    final double cp2X = 36.w; // Smooths the bottom valley

    final paint = Paint()
      ..color = const Color(0xFF0F1012)
      ..style = PaintingStyle.fill;

    // Draw the main card body path with smooth fluid curves
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, flatY + 30.r)
      ..arcToPoint(
        Offset(30.r, flatY),
        radius: Radius.circular(30.r),
        clockwise: true,
      )
      ..lineTo(w / 2 + xs, flatY)
      // Left fluid shoulder and valley
      ..cubicTo(
        w / 2 + xs + cp1X,
        flatY, // Control point 1
        w / 2 - cp2X,
        flatY + dipDepth, // Control point 2
        w / 2,
        flatY + dipDepth, // Bottom center
      )
      // Right fluid valley and shoulder
      ..cubicTo(
        w / 2 + cp2X,
        flatY + dipDepth, // Control point 1
        w / 2 - xs - cp1X,
        flatY, // Control point 2
        w / 2 - xs,
        flatY, // Back to flat line
      )
      ..lineTo(w - 30.r, flatY)
      ..arcToPoint(
        Offset(w, flatY + 30.r),
        radius: Radius.circular(30.r),
        clockwise: true,
      )
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33FFFFFF), // rgba(255, 255, 255, 0.2)
          Color(0x00FFFFFF), // rgba(255, 255, 255, 0)
        ],
        stops: [0.0, 0.8673],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Draw the highlight outline matching the fluid curves exactly
    final borderPath = Path()
      ..moveTo(0, flatY + 30.r)
      ..arcToPoint(
        Offset(30.r, flatY),
        radius: Radius.circular(30.r),
        clockwise: true,
      )
      ..lineTo(w / 2 + xs, flatY)
      ..cubicTo(
        w / 2 + xs + cp1X,
        flatY,
        w / 2 - cp2X,
        flatY + dipDepth,
        w / 2,
        flatY + dipDepth,
      )
      ..cubicTo(
        w / 2 + cp2X,
        flatY + dipDepth,
        w / 2 - xs - cp1X,
        flatY,
        w / 2 - xs,
        flatY,
      )
      ..lineTo(w - 30.r, flatY)
      ..arcToPoint(
        Offset(w, flatY + 30.r),
        radius: Radius.circular(30.r),
        clockwise: true,
      );

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final double flatY = 24.r; // Top flat line Y
    final double dipWidth = 156.w; // Total width of the dip
    final double dipDepth = 26.r; // Depth of the dip below flatY
    final double xs = -dipWidth / 2;

    // Control point offsets for elegant "squircle" curve transitions
    final double cp1X = 36.w; // Smooths the top shoulder
    final double cp2X = 36.w; // Smooths the bottom valley

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, flatY + 30.r)
      ..arcToPoint(
        Offset(30.r, flatY),
        radius: Radius.circular(30.r),
        clockwise: true,
      )
      ..lineTo(w / 2 + xs, flatY)
      // Left fluid shoulder and valley
      ..cubicTo(
        w / 2 + xs + cp1X,
        flatY, // Control point 1
        w / 2 - cp2X,
        flatY + dipDepth, // Control point 2
        w / 2,
        flatY + dipDepth, // Bottom center
      )
      // Right fluid valley and shoulder
      ..cubicTo(
        w / 2 + cp2X,
        flatY + dipDepth, // Control point 1
        w / 2 - xs - cp1X,
        flatY, // Control point 2
        w / 2 - xs,
        flatY, // Back to flat line
      )
      ..lineTo(w - 30.r, flatY)
      ..arcToPoint(
        Offset(w, flatY + 30.r),
        radius: Radius.circular(30.r),
        clockwise: true,
      )
      ..lineTo(w, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
