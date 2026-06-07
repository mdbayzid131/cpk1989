import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Obx(() {
        if (controller.rxItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFF0CA)),
            ),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.rxItems.length,
          itemBuilder: (context, index) {
            final item = controller.rxItems[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-screen background image
                Image.asset(item.imagePath, fit: BoxFit.cover),

                // 2. Dark gradient overlay to ensure text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Top Header Overlay (Closeté logo)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16.h,
                  left: 20.w,
                  child: Text(
                    'Closeté',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // 4. Bottom Information Overlay
                Positioned(
                  bottom:
                      104.h +
                      MediaQuery.of(context)
                          .padding
                          .bottom, // dynamically clears the bottom navigation bar height on all devices
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Info & Price badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // User profile info
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: Colors.grey.shade900,
                                  child: ClipOval(
                                    child: Image.network(
                                      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150",
                                      width: 40.r,
                                      height: 40.r,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white70,
                                              ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    item.userName,
                                    style: GoogleFonts.manrope(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.isVerified) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.verified,
                                    color: const Color(0xFF00A2FF),
                                    size: 16.sp,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),

                          // Price Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              item.price,
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Condition Status
                      Text(
                        item.condition,
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Item Title & "View More" link
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.itemName,
                              style: GoogleFonts.manrope(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.itemDetail,
                                arguments: item,
                              );
                            },
                            child: Text(
                              "View More",
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                                decorationThickness: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Trust badge (Authenticity guaranteed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: Colors.white,
                              size: 15.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Authenticity guaranteed. Payment protected.",
                              style: GoogleFonts.manrope(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Secure This Item Button (Gradient)
                      CustomGoldButton(
                        text: "Secure This Item",
                        suffix: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 18,
                        ),
                        onTap: () {
                          showProcessingOverlay(context, () {
                            // Close bottom sheet first
                            Get.back();
                            Get.toNamed(AppRoutes.secureCheckout, arguments: item);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
