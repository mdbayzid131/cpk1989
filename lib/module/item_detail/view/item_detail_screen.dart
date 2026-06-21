import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/module/item_detail/controller/item_detail_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';

class ItemDetailScreen extends GetView<ItemDetailController> {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Scrollable Content + Bottom Action Bar
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image Card
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(24.r),
                              ),
                              child: Container(
                                height: 380.h,
                                width: double.infinity,
                                color: Colors.black,
                                child: item.imagePath.startsWith('http')
                                    ? Image.network(
                                        item.imagePath,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        item.imagePath,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            // Vignette overlay
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(24.r),
                                ),
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
                            // Price tag bottom right
                            Positioned(
                              bottom: -22.h,
                              right: 16.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item.price,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32.h),

                        // Scrollable content wrapped in horizontal padding
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2. Seller Profile row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      SizedBox(width: 10.w),
                                      Text(
                                        item.userName,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16.sp,
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
                                  Text(
                                    "Listed price",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
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
                                style: GoogleFonts.dmSans(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              // 4. Specifications row (Condition & Worn Count & Size)
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12.w,
                                runSpacing: 8.h,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/Excellent condition  Warn Twice.svg',
                                        width: 16.r,
                                        height: 16.r,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        "${item.condition} : ${item.wornCount}",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13.sp,
                                          color: const Color(0xFFA2A2A2),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 12.h,
                                    width: 1.w,
                                    color: Colors.white12,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.straighten_outlined,
                                        color: const Color(0xFFA2A2A2),
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        item.size,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13.sp,
                                          color: const Color(0xFFA2A2A2),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),
                              const Divider(color: Colors.white10),
                              SizedBox(height: 24.h),

                              // 5. Description
                              Text(
                                "DESCRIPTION",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                item.description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // 6. Security Assurances Grid/Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Authenticity Verified.svg',
                                      label: "Authenticity\nVerified",
                                    ),
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 36.h,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Payment Protected .svg',
                                      label: "Payment\nProtected",
                                    ),
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 36.h,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Secure Delivery.svg',
                                      label: "Secure\nDelivery",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
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
                      showProcessingOverlay(context, () {
                        Get.toNamed(AppRoutes.secureCheckout, arguments: item);
                      });
                    },
                  ),
                ),
              ],
            ),

            // 2. Fixed Top Navigation Controls (Floats above layout)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              right: 16.w,
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

  Widget _buildSecurityBadge({required String svgPath, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(svgPath, width: 24.r, height: 24.r),
        SizedBox(height: 10.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
