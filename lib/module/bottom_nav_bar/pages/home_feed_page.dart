import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Full Screen Background Product Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/luxury_bag.png',
            fit: BoxFit.cover,
          ),
        ),

        // 2. Dark Gradient Overlay from bottom to top for readability of overlays
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // 3. Elegant Logo Top-Left (Floating)
        Positioned(
          top: 60.h,
          left: 24.w,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFF0CA),
                Color(0xFFF9E49B),
                Color(0xFFD4AF37),
                Color(0xFFB38915),
              ],
            ).createShader(bounds),
            child: Text(
              'Closeté',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        // 4. Overlaid Product Details & Actions (Bottom Section)
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 120.h, // Positioned above the custom bottom navigation bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seller Info Row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                        width: 36.w,
                        height: 36.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 36.w,
                          height: 36.w,
                          color: const Color(0xFFD4AF37),
                          alignment: Alignment.center,
                          child: Text(
                            'OM',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Olivia Mendes',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFF00A2FF),
                    size: 16.sp,
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Title and Price Tag Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Product title & condition
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excellent condition',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Classic Flap Bag',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'View More',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'AED 3,200',
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F1012),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Translucent Trust Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: const Color(0xFFD4AF37),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Authenticity guaranteed. Payment protected.',
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Premium "Secure This Item" button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFF0CA),
                        Color(0xFFF9E49B),
                        Color(0xFFD4AF37),
                        Color(0xFFB38915),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40D4AF37),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Secure This Item',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F1012),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF0F1012),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
