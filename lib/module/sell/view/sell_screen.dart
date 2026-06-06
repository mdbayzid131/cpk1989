import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161719),
        title: Text(
          "Sell Wardrobe Item",
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
            color: const Color(0xFFFFF0CA),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 80.sp,
              color: const Color(0xFFFFF0CA),
            ),
            SizedBox(height: 24.h),
            Text(
              "List a Luxury Item",
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              "Scan your luxury items, upload images/videos, and detail the specifications to publish it in the digital wardrobe.",
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: Colors.white54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0CA),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              onPressed: () {
                Get.snackbar(
                  "Scan Closet",
                  "Starting wardrobe analyzer...",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFFFFF0CA),
                  colorText: Colors.black,
                );
              },
              child: Text(
                "Scan Wardrobe",
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
