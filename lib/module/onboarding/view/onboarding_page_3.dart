import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 70.h),

        ///<================= HEADER TEXT =========================>///
        Text(
          'Shop with',
          style: TextStyle(
            fontFamily: 'Schnyder L',
            fontSize: 38.sp,
            fontWeight: FontWeight.w300,
            color: AppTheme.primaryText,
            height: 1.15,
          ),
        ),
        SizedBox(height: 5.h),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.goldGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
          child: Text(
            'Confidence',
            style: TextStyle(
              fontFamily: 'Schnyder L',
              fontSize: 38.sp,
              fontWeight: FontWeight.w300,
              color: AppTheme.primaryText,
              height: 1.15,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Small gold horizontal accent line
        Container(
          width: 32.w,
          height: 2.h,
          decoration: BoxDecoration(gradient: AppTheme.goldGradient),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Verified before delivery. Payment\nprotected until you receive it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.grayTerritory,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(),

        ///<================= MAIN HANDOVER IMAGE (FULL SCREEN WIDTH) =========================>///
        Container(
          width: double.infinity,
          height: 320.h,
          color: Colors.transparent,
          child: Stack(
            children: [
              // 1. Handover Image Background
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bag_handover.png',
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
            ],
          ),
        ),
        const Spacer(),

        ///<================= FEATURES GRID / ROW =========================>///
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Authenticity Guaranteed
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Authenticity Verified.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Authenticity\nVerified',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1.w,
                height: 36.h,
                color: Colors.white.withValues(alpha: 0.15),
              ),

              // 2. Payment Protected
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Payment Protected .svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Payment\nProtected',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1.w,
                height: 36.h,
                color: Colors.white.withValues(alpha: 0.15),
              ),

              // 3. Secure Delivery
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Secure Delivery.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Secure\nDelivery',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 50.h),

        const Spacer(flex: 3),
      ],
    );
  }
}
