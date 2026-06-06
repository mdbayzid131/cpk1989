import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/constants/image_paths.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        ///<================= DESCRIPTION TEXT =========================>///
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Cleaned by locals\nyou trust',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff101828),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Trusted local cleaners. Fully coordinated\npickup and delivery.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff4A5565),
            ),
          ),
        ),
        const Spacer(),

        ///<================= COMPARISON ILLUSTRATION =========================>///
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xffF9FAFB),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildComparisonBadge('Before'),
                  _buildComparisonBadge('After'),
                ],
              ),
              SizedBox(height: 20.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(ImagePaths.onboardingImage2, fit: BoxFit.contain),
                  Icon(Icons.arrow_forward, size: 28.sp, color: Colors.black87),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildComparisonBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xffA6D4E9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
