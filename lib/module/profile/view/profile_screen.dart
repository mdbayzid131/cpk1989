import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: const Color(0xFF282A2E),
              child: Icon(
                Icons.person,
                size: 50.sp,
                color: const Color(0xFFFFF0CA),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Alexander Rossi",
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Premium Member",
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: const Color(0xFFFFF0CA),
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF282A2E),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              onPressed: () {
                Get.offAllNamed(AppRoutes.splash);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }
}
