import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  top: MediaQuery.of(context).padding.top + 25.h,
                  left: 20.w,
                  child: Text(
                    'Closeté',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Schnyder L',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 0.0,
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
                      // User Info Row (Avatar + Username + Verified badge)
                      Row(
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
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            item.userName,
                            style: GoogleFonts.dmSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          if (item.isVerified) ...[
                            SizedBox(width: 6.w),
                            SvgPicture.asset(
                              'assets/icons/blue_verify-badg.svg',
                              width: 18.r,
                              height: 18.r,
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Item Details (Condition, Name, View More on left; Price Badge on right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.condition,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.sp,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.itemName,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.itemDetail,
                                          arguments: item,
                                        );
                                      },
                                      child: Text(
                                        "View More",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          decorationThickness: 1.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Right Price Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              item.price,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Trust badge (Authenticity guaranteed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/Authenticity guarante_ home page logo.svg',
                              width: 14.r,
                              height: 14.r,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Authenticity guaranteed. Payment protected.",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w400,
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
                            Get.toNamed(
                              AppRoutes.secureCheckout,
                              arguments: item,
                            );
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
