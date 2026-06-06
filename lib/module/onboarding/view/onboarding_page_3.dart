import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/constants/image_paths.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        ///<================= DESCRIPTION TEXT =========================>///
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Delivery included\nevery month',
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
            'Join LaundryLink for \$14.99/month and\nenjoy free delivery',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xff4A5565),
            ),
          ),
        ),
        const Spacer(),

        ///<================= MAIN ILLUSTRATION =========================>///
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
   
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
         
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              ImagePaths.onboardingImage3,
              height: 245.w,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
