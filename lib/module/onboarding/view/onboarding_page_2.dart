import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100.h),

        ///<================= DESCRIPTION TEXT =========================>///
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Verify it. Trust it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Every item is physically inspected and verified by our local luxury experts before being listed.',
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

        ///<================= ILLUSTRATION CARD =========================>///
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFF161719),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              'assets/images/closet_scan.png',
              height: 250.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const Spacer(flex: 2),
      ],
    );
  }
}
