import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/wishlist/controller/wishlist_controller.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';

class WishlistScreen extends GetView<WishlistController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE2B744),
          backgroundColor: const Color(0xFF1E2022),
          onRefresh: () => controller.fetchWishlist(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),

                // Title Header (Left-aligned as shown in mockup)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    "Wishlist",
                    style: GoogleFonts.dmSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Grid Content
                Obx(() {
                  if (controller.rxIsLoading.value &&
                      controller.rxItems.isEmpty) {
                    return Container(
                      height: 400.h,
                      alignment: Alignment.center,
                      child: CustomGoldLoader(size: 40.r, strokeWidth: 3.5.r),
                    );
                  }

                  final items = controller.rxItems;
                  if (items.isEmpty) {
                    return _buildEmptyWishlistState(context);
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 175 / 204,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildWishlistCard(item);
                    },
                  );
                }),

                // Bottom spacing to avoid overlap with bottom navigation bar
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistCard(WishlistItem item) {
    return GestureDetector(
      onTap: () {
        if (item.rawProduct != null) {
          final feedItem = FeedItem.fromProductModel(item.rawProduct!);
          Get.toNamed(AppRoutes.itemDetail, arguments: feedItem);
        } else {
          final formattedPrice =
              "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
          final feedItem = FeedItem(
            id: item.id,
            imagePath: item.imageUrl,
            userName: '',
            condition: item.condition ?? '',
            itemName: item.itemName,
            brand: item.brand,
            price: formattedPrice,
            size: '',
            wornCount: '',
            description: item.description ?? '',
            images: item.imageUrl.isNotEmpty ? [item.imageUrl] : [],
          );
          Get.toNamed(AppRoutes.itemDetail, arguments: feedItem);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF292A2D), Color(0xFF1C1D21)],
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
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
                        child: Icon(Icons.broken_image, color: Colors.white38),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 10.h), // Gap: 10px
            // 2. Bottom Details Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand & Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.brand.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white38,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.itemName,
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Red Heart Squircle button (Matches design)
                      Obx(() {
                        final isRemoving = controller.rxRemovingIds.contains(
                          item.id,
                        );
                        return GestureDetector(
                          onTap: () => controller.toggleFavorite(item.id),
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: isRemoving
                                    ? Colors.white
                                    : const Color(0xFFFF453A),
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 10.h), // Gap: 10px
                  // Price Tag Capsule
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWishlistState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Wishlist PNG Illustration matching design
          SvgPicture.asset(
            'assets/images/wishlist.svg',
            width: 220.r,
            height: 220.r,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.favorite_rounded,
                size: 80.r,
                color: const Color(0xFFFF453A),
              );
            },
          ),
          SizedBox(height: 20.h),

          // 2. Title
          Text(
            "Nothing Saved Yet",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // 3. Subtitle
          Text(
            "Start exploring luxury pieces\nyou love",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),

          // 4. Explore Items Gold Button
          CustomGoldButton(
            text: "Explore Items",
            width: 320.w,
            height: 50.h,
            suffix: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 18.sp,
            ),
            onTap: () {
              if (Get.isRegistered<BottomNavBarController>()) {
                Get.find<BottomNavBarController>().changeIndex(0);
              } else {
                Get.offAllNamed(AppRoutes.bottomNavBar);
              }
            },
          ),
        ],
      ),
    );
  }
}
