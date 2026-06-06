import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64.sp,
              color: const Color(0xFFFFF0CA),
            ),
            SizedBox(height: 16.h),
            Text(
              "My Wishlist",
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Starred luxury items will appear here.",
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
