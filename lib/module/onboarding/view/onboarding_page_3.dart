import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
          style: GoogleFonts.playfairDisplay(
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
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'Confidence',
            style: GoogleFonts.playfairDisplay(
              fontSize: 38.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Small gold horizontal accent line
        Container(
          width: 32.w,
          height: 2.h,
          color: const Color(0xFFC98C28),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Verified before delivery. Payment\nprotected until you receive it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.55),
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
                        const Color(0xFF0A0A0C),
                        const Color(0xFF0A0A0C).withValues(alpha: 0.0),
                        const Color(0xFF0A0A0C).withValues(alpha: 0.0),
                        const Color(0xFF0A0A0C),
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
                    Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Authenticity\nGuaranteed',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
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
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Payment\nProtected',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
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
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Secure\nDelivery',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
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

        const Spacer(flex: 3),
      ],
    );
  }
}
