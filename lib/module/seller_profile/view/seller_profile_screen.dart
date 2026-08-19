import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/module/seller_profile/controller/seller_profile_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

class SellerProfileScreen extends GetView<SellerProfileController> {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),

              // Header Row (Back Button + Page Title)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    CustomGlassButton(
                      onTap: () => Get.back(),
                      size: 36.r,
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      "Seller Profile",
                      style: GoogleFonts.dmSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Profile Card Details
              _buildProfileCard(context),

              SizedBox(height: 16.h),
              const Divider(color: Colors.white10, height: 1),
              SizedBox(height: 16.h),

              // Seller Closet Grid
              _buildSellerItemsGrid(),

              // Bottom spacing
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular avatar (Without edit button)
          // Circular avatar (Without edit button)
          Obx(
            () => CircleAvatar(
              radius: 46.r,
              backgroundColor: const Color(0xFF282A2E),
              backgroundImage: (controller.rxAvatarUrl.value.isNotEmpty &&
                      controller.rxAvatarUrl.value.startsWith('http'))
                  ? NetworkImage(controller.rxAvatarUrl.value)
                  : const NetworkImage("https://i.ibb.co/z5YHLV9/profile.png"),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + verified check icon
                Obx(
                  () => Row(
                    children: [
                      Text(
                        controller.rxUserName.value,
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (controller.rxIsVerified.value) ...[
                        SizedBox(width: 6.w),
                        SvgPicture.asset(
                          'assets/icons/blue_verify-badg.svg',
                          width: 16.w,
                          height: 16.h,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Translucent Stats Container (Label on TOP, Value on BOTTOM)
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 4.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            "Items Listed",
                            controller.itemsListedCount.toString(),
                          ),
                        ),
                        _buildStatDivider(),
                        Expanded(
                          child: _buildStatItem(
                            "Items Sold",
                            controller.itemsSoldCount.toString(),
                          ),
                        ),
                        _buildStatDivider(),
                        Expanded(
                          child: _buildStatItem(
                            "Closet Value",
                            controller.closetValueFormatted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white38,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 24.h,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildSellerItemsGrid() {
    return Obx(() {
      if (controller.rxIsLoading.value && controller.rxItems.isEmpty) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: CustomGoldLoader(size: 36.r, strokeWidth: 3.5.r),
        );
      }

      final items = controller.rxItems;
      if (items.isEmpty) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: Text(
            "Closet is empty.",
            style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14.sp),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridCard(context, item);
        },
      );
    });
  }

  Widget _buildGridCard(BuildContext context, ProfileItem item) {
    // Format Price nicely with commas
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    // Format Likes count (e.g. 2000 -> 2K)
    final formattedLikes = item.likes >= 1000
        ? "${(item.likes / 1000).toStringAsFixed(0)}K"
        : "${item.likes}";

    return GestureDetector(
      onTap: () {
        // Convert ProfileItem to FeedItem to fit ItemDetailScreen model
        final feedItem = FeedItem(
          id: item.id,
          sellerId: controller.rxSellerId.value,
          imagePath: item.imageUrl,
          userName: controller.rxUserName.value,
          condition: "Excellent",
          itemName: item.itemName,
          price: formattedPrice,
          size: "Medium",
          wornCount: "Worn Twice",
          description:
              "${item.brand} ${item.itemName} in pristine condition.",
          isVerified: controller.rxIsVerified.value,
          images: item.itemImages,
          sellerProfileImage: controller.rxAvatarUrl.value,
        );
        Get.toNamed(AppRoutes.itemDetail, arguments: feedItem);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Product image
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1E2022),
                  child: Center(
                    child: CustomGoldLoader(size: 24.r, strokeWidth: 2.5.r),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1E2022),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white30),
                  ),
                );
              },
            ),

            // 2. Details footer showing Price & Likes
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Likes (Outline heart ♡ + text)
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          formattedLikes,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Price
                    Text(
                      formattedPrice,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
