import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/module/item_detail/controller/item_detail_controller.dart';

class ItemDetailScreen extends GetView<ItemDetailController> {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Scrollable Content + Bottom Action Bar
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image Card
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Container(
                                height: 380.h,
                                width: double.infinity,
                                color: Colors.black,
                                child: Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Vignette overlay
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.2),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Play button overlay in center
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                ),
                              ),
                            ),
                            // Price tag bottom right
                            Positioned(
                              bottom: 16.h,
                              right: 16.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
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
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // 2. Seller Profile row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                Text(
                                  item.userName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                            Text(
                              "Listed price",
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // 3. Item Title
                        Text(
                          item.itemName,
                          style: GoogleFonts.manrope(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // 4. Specifications row (Condition & Worn Count & Size)
                        Row(
                          children: [
                            Icon(
                              Icons.star_border,
                              color: Colors.white70,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${item.condition} : ${item.wornCount}",
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              height: 12.h,
                              width: 1.w,
                              color: Colors.white24,
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.straighten_outlined,
                              color: Colors.white70,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              item.size,
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                        const Divider(color: Colors.white10),
                        SizedBox(height: 20.h),

                        // 5. Description
                        Text(
                          "DESCRIPTION",
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white38,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item.description,
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // 6. Security Assurances Grid/Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSecurityBadge(
                              icon: Icons.verified_user_outlined,
                              label: "Authenticity\nGuaranteed",
                            ),
                            _buildSecurityBadge(
                              icon: Icons.lock_outline,
                              label: "Payment\nProtected",
                            ),
                            _buildSecurityBadge(
                              icon: Icons.local_shipping_outlined,
                              label: "Secure\nDelivery",
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),

                // 7. Persistent Gold Action Button at Bottom
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1012),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: CustomGoldButton(
                    text: "Secure This Item",
                    suffix: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 18,
                    ),
                    onTap: () {
                      Get.snackbar(
                        "Order Secured",
                        "Securing item: ${item.itemName}...",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFFD4AF37),
                        colorText: Colors.black,
                      );
                    },
                  ),
                ),
              ],
            ),

            // 2. Fixed Top Navigation Controls (Floats above layout)
            Positioned(
              top: 32.h,
              left: 32.w,
              right: 32.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomGlassButton(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  Obx(() {
                    final isFav = controller.rxIsFavorite.value;
                    return CustomGlassButton(
                      onTap: controller.toggleFavorite,
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : Colors.white,
                        size: 18.sp,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        SizedBox(height: 10.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
