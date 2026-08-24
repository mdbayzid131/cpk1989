import 'dart:io';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_add_card_bottom_sheet.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/widgets/custom_empty_state.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFE2B744),
          backgroundColor: const Color(0xFF1E2022),
          onRefresh: () => controller.fetchProfileApiData(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                if (controller.rxSelectedIndex.value == 1) {
                  controller.loadMorePurchases();
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),

                // Screen Header (Left-aligned as shown in mockup)
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 0.w,
                    top: 8.h,
                    bottom: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Profile",
                        style: GoogleFonts.dmSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        alignment: Alignment.centerRight,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white54,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Profile Card Details (Horizontal layout matching mockup)
                _buildProfileCard(context),

                SizedBox(height: 20.h),

                // Navigation Tabs
                _buildNavigationTabs(),

                SizedBox(height: 16.h),

                // Selected Tab Content
                Obx(() {
                  final tabIndex = controller.rxSelectedIndex.value;
                  switch (tabIndex) {
                    case 0:
                      return _buildWardrobeGrid();
                    case 1:
                      return _buildPurchasesGrid();
                    case 2:
                      return _buildPersonalDetails(context);
                    default:
                      return const SizedBox.shrink();
                  }
                }),

                // Bottom spacing to avoid overlap with floating bottom navigation bar
                SizedBox(height: 120.h),
              ],
            ),
          ),
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
          // Circular avatar with edit badge
          Stack(
            children: [
              Obx(() {
                final img = controller.rxProfileImage.value;
                String fullUrl = img;
                if (fullUrl.isNotEmpty &&
                    !fullUrl.startsWith('http://') &&
                    !fullUrl.startsWith('https://')) {
                  final serverBase = ApiConstants.baseUrl.replaceAll(
                    RegExp(r'/api/v1/?$'),
                    '',
                  );
                  fullUrl = fullUrl.startsWith('/')
                      ? '$serverBase$fullUrl'
                      : '$serverBase/$fullUrl';
                }

                return CircleAvatar(
                  radius: 46.r,
                  backgroundColor: const Color(0xFF282A2E),
                  backgroundImage: fullUrl.isNotEmpty
                      ? NetworkImage(fullUrl)
                      : null,
                  child: fullUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 40.r,
                          color: Colors.white70,
                        )
                      : null,
                );
              }),
              Positioned(
                bottom: 0,
                right: 0,
                child: CustomGlassButton(
                  size: 24.r,
                  padding: EdgeInsets.zero,
                  glassColor: Colors.grey.withValues(alpha: 0.35),
                  onTap: () => _showImageSourceBottomSheet(context),
                  child: SvgPicture.asset(
                    'assets/icons/edit pen .svg',
                    width: 12.r,
                    height: 12.r,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
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
                        controller.rxUserName.value.isNotEmpty
                            ? controller.rxUserName.value
                            : 'Profile',
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      SvgPicture.asset(
                        'assets/icons/blue_verify-badg.svg',
                        width: 16.w,
                        height: 16.h,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Translucent Stats Container (Dynamic counts from API)
                Obx(() {
                  final stats = controller.rxProfileStats.value;
                  final wardrobeCount = stats.totalProductsListed > 0
                      ? stats.totalProductsListed
                      : controller.rxWardrobeItems.length;
                  final purchasesCount = stats.totalProductsPurchased > 0
                      ? stats.totalProductsPurchased
                      : controller.rxPurchaseItems.length;
                  final earningsText = stats.totalEarnings > 0
                      ? "${stats.currency} ${stats.formattedEarnings}"
                      : "AED 0";

                  return Container(
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
                            "$wardrobeCount",
                          ),
                        ),
                        _buildStatDivider(),
                        Expanded(
                          child: _buildStatItem("Purchases", "$purchasesCount"),
                        ),
                        _buildStatDivider(),
                        Expanded(
                          child: _buildStatItem(
                            "Earnings",
                            earningsText,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2022),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Update Profile Photo",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Choose photo source",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                // Camera Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      controller.updateProfileImage(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282A2E),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2B744).withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: const Color(0xFFE2B744),
                              size: 24.r,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Camera",
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // Gallery Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      controller.updateProfileImage(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282A2E),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2B744).withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: const Color(0xFFE2B744),
                              size: 24.r,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Gallery",
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey, // Grey-ish label matching mockup
          ),
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white, // White bold value matching mockup
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24.h,
      width: 1.w,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _buildNavigationTabs() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Obx(() {
            final selectedIndex = controller.rxSelectedIndex.value;
            return Row(
              children: [
                _buildTabItem("MY WARDROBE", 0, selectedIndex),
                SizedBox(width: 24.w),
                _buildTabItem("MY PURCHASES", 1, selectedIndex),
                SizedBox(width: 24.w),
                _buildTabItem("PERSONAL DETAILS", 2, selectedIndex),
              ],
            );
          }),
        ),
        Divider(
          color: Colors.white.withValues(alpha: 0.08),
          thickness: 1.0,
          height: 1.0,
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFFAF2C)
                    : const Color(0xFF8E8E93),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2.h,
              width: isSelected ? 45.w : 0.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE2B744), // Gold indicator
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeGrid() {
    return Obx(() {
      if (controller.rxIsLoadingWardrobe.value) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: CustomGoldLoader(size: 40.r),
        );
      }

      final items = controller.rxWardrobeItems;
      if (items.isEmpty) {
        return CustomEmptyState(
          imagePath: 'assets/images/my_wardrobe.svg',
          imageSize: 130.r,
          fallbackIcon: Icons.checkroom_rounded,
          title: "You Haven't Listed Anything Yet",
          subtitle: "Turn your wardrobe into cash in\nseconds",
          buttonText: "Sell Your First Item",
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          onButtonTap: () {
            Get.toNamed(AppRoutes.sell);
          },
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
          childAspectRatio: 0.82, // Matched height ratio
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridCard(context, item, isWardrobe: true);
        },
      );
    });
  }

  Widget _buildPurchasesGrid() {
    return Obx(() {
      if (controller.rxIsLoadingOrders.value) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: CustomGoldLoader(size: 40.r),
        );
      }

      final items = controller.rxPurchaseItems;
      if (items.isEmpty) {
        return CustomEmptyState(
          imagePath: 'assets/images/my_purchases.svg',
          imageSize: 130.r,
          fallbackIcon: Icons.shopping_bag_outlined,
          title: "No Orders Yet",
          subtitle: "Start exploring luxury pieces\nfrom real women",
          buttonText: "Explore Items",
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          onButtonTap: () {
            if (Get.isRegistered<BottomNavBarController>()) {
              Get.find<BottomNavBarController>().changeIndex(0);
            } else {
              Get.offAllNamed(AppRoutes.bottomNavBar);
            }
          },
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            ...items.map((item) => _buildPurchaseCard(item)),
            if (controller.rxIsLoadingMoreOrders.value) ...[
              SizedBox(height: 16.h),
              Center(
                child: CustomGoldLoader(size: 28.r, strokeWidth: 3.r),
              ),
              SizedBox(height: 16.h),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPurchaseCard(ProfileItem item) {
    final status = item.displayStatus;
    final isDelivered = status == "Delivered";
    final statusColor = isDelivered
        ? const Color(0xFF30D158)
        : const Color(0xFFFFAF2C);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.myPurchaseDetails, arguments: item);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF292A2D), Color(0xFF1C1D21)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Left details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          status,
                          style: GoogleFonts.dmSans(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Item Name
                  Text(
                    item.itemName,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Price
                  Text(
                    "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: AppTheme.gray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16.w),

            // Right product photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child:
                  item.imageUrl.isNotEmpty && item.imageUrl.startsWith('http')
                  ? Image.network(
                      item.imageUrl,
                      width: 102.r,
                      height: 102.r,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 102.r,
                          height: 102.r,
                          color: const Color(0xFF1E2022),
                          child: Center(
                            child: CustomGoldLoader(
                              size: 24.r,
                              strokeWidth: 2.5.r,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 102.r,
                          height: 102.r,
                          color: const Color(0xFF1E2022),
                          child: const Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white30,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 102.r,
                      height: 102.r,
                      color: const Color(0xFF1E2022),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white30,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    ProfileItem item, {
    required bool isWardrobe,
  }) {
    // Format Price nicely with commas
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    // Format Likes count (e.g. 2000 -> 2K)
    final formattedLikes = item.likes >= 1000
        ? "${(item.likes / 1000).toStringAsFixed(0)}K"
        : "${item.likes}";

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.myItemDetail, arguments: item);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Product image with lazy loading (supports both network and local paths)
            item.imageUrl.startsWith('http')
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF1E2022),
                        child: Center(
                          child: CustomGoldLoader(
                            size: 24.r,
                            strokeWidth: 2.5.r,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1E2022),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white30,
                          ),
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(item.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1E2022),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white30,
                          ),
                        ),
                      );
                    },
                  ),

            // 2. Dark Overlay for sold items
            if (item.isSold)
              Container(color: Colors.black.withValues(alpha: 0.55)),

            // 3. Top-left "Sold" capsule badge (Matched mockup styling)
            if (item.isSold)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFAF2C,
                    ), // Solid Gold background matching mockup
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    isWardrobe ? "Sold" : item.displayStatus,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

            // 4. Delete squircle button (Visible on wardrobe items only, hidden on sold items)
            if (isWardrobe && !item.isSold)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => _showRemoveBottomSheet(context, item),
                  child: Container(
                    height: 32.r,
                    width: 32.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/delete .svg',
                        width: 14.r,
                        height: 14.r,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Details footer showing Price & Likes (Matches layout exactly)
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

  Widget _buildPersonalDetails(BuildContext context) {
    return Obx(() {
      final isEditing = controller.rxIsEditing.value;
      final isLoading = controller.rxIsLoadingProfile.value;

      if (isLoading) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: CustomGoldLoader(size: 40.r),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details Header + Pen Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DETAILS",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white60,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.rxIsEditing.toggle();
                  },
                  child: SvgPicture.asset(
                    'assets/icons/edit pen .svg',
                    width: 20.r,
                    height: 20.r,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFFAF2C),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // First Name
            _buildInputField(
              controller: controller.firstNameController,
              prefixIcon: 'assets/icons/person.svg',
              hintText: "Enter first name here",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Last Name
            _buildInputField(
              controller: controller.lastNameController,
              prefixIcon: 'assets/icons/person.svg',
              hintText: "Enter last name here",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Location
            _buildInputField(
              controller: controller.locationController,
              prefixIcon: 'assets/icons/location.svg',
              hintText: "Enter location here",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Country
            _buildInputField(
              controller: controller.countryController,
              prefixIcon: 'assets/icons/location.svg',
              hintText: "Enter country here",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Phone Number
            _buildPhoneInputField(
              controller.phoneController,
              hintText: "Enter number here",
              isEditing: isEditing,
              readOnly: !isEditing,
            ),

            SizedBox(height: 32.h),

            // Save Changes Gold Button (matches mockup)
            if (isEditing) ...[
              CustomGoldButton(
                text: "Save Changes",
                suffix: Icon(
                  Icons.arrow_forward,
                  size: 16.r,
                  color: Colors.black,
                ),
                onTap: () => controller.saveChanges(),
              ),
              SizedBox(height: 32.h),
            ],

            _buildSavedCardsSection(context),
          ],
        ),
      );
    });
  }

  Widget _buildSavedCardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final cards = controller.rxSavedCards;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SAVED CARDS",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 1.0,
                ),
              ),
              if (cards.isNotEmpty)
                GestureDetector(
                  onTap: () => _showAddCardBottomSheet(context),
                  child: Text(
                    "Add a new card",
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: const Color(0xFFFFAF2C),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFFFAF2C),
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 16.h),
        Obx(() {
          final cards = controller.rxSavedCards;
          if (cards.isEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFF161719),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.string(
                    '''<svg width="40" height="31" viewBox="0 0 40 31" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M0 26.0156C0 27.321 0.518553 28.5729 1.44158 29.4959C2.36461 30.4189 3.61651 30.9375 4.92188 30.9375H34.4531C35.7585 30.9375 37.0104 30.4189 37.9334 29.4959C38.8564 28.5729 39.375 27.321 39.375 26.0156V12.4805H0V26.0156ZM5.80078 19.3359C5.80078 18.6366 6.07858 17.966 6.57306 17.4715C7.06754 16.977 7.7382 16.6992 8.4375 16.6992H12.6562C13.3556 16.6992 14.0262 16.977 14.5207 17.4715C15.0152 17.966 15.293 18.6366 15.293 19.3359V21.0938C15.293 21.7931 15.0152 22.4637 14.5207 22.9582C14.0262 23.4527 13.3556 23.7305 12.6562 23.7305H8.4375C7.7382 23.7305 7.06754 23.4527 6.57306 22.9582C6.07858 22.4637 5.80078 21.7931 5.80078 21.0938V19.3359ZM34.4531 0H4.92188C3.61651 0 2.36461 0.518553 1.44158 1.44158C0.518553 2.36461 0 3.61651 0 4.92188V7.20703H39.375V4.92188C39.375 3.61651 38.8564 2.36461 37.9334 1.44158C37.0104 0.518553 35.7585 0 34.4531 0Z" fill="white" fill-opacity="0.1"/>
</svg>''',
                    width: 40.r,
                    height: 31.r,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "No saved cards",
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Add a payment method to make secure purchases or get paid after your buyer accepts delivery",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: const Color(0xFFA2A2A2),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => _showAddCardBottomSheet(context),
                    child: Text(
                      "+ Add payment method",
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        color: const Color(0xFFFFAF2C),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFFAF2C),
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(cards.length, (index) {
                final card = cards[index];
                final type = card.brand.toUpperCase();
                final logo = card.brand.toLowerCase();
                final cardNumber = card.maskedNumber;
                final expiry = card.expiry;
                final isVerified = true;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161719),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCardLogo(logo),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  cardNumber,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.sp,
                                    color: Colors.white38,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                expiry,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  color: Colors.white38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () =>
                                    controller.deleteSavedCard(card.id),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white38,
                                  size: 18.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isVerified) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF34C759,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100.r),
                            border: Border.all(
                              color: const Color(
                                0xFF34C759,
                              ).withValues(alpha: 0.15),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: const Color(0xFF34C759),
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Verified for payments",
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF34C759),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            );
          }
        }),
      ],
    );
  }

  Widget _buildProfileCardLogo(String logo) {
    if (logo == 'visa') {
      return Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: const Color(0xFF161719), // Branded dark background
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "VISA",
          style: GoogleFonts.dmSans(
            color: const Color(0xFF2566AF), // Branded Visa blue
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 14.sp,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else if (logo == 'mastercard') {
      return Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: const Color(
            0xFF161719,
          ), // Mastercard dark container background
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.r),
        child: SvgPicture.asset(
          'assets/icons/master_card_colored.svg',
          fit: BoxFit.contain,
        ),
      );
    } else {
      // General red card logo box
      return Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: const Color(0xFFDA3D28), // Mastercard red background
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.r),
        child: SvgPicture.asset(
          'assets/icons/master card.svg',
          fit: BoxFit.contain,
        ),
      );
    }
  }

  void _showAddCardBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CustomAddCardBottomSheet(
        onAdd:
            ({
              required String name,
              required String cardNumber,
              required String expiry,
              required String cvv,
            }) async {
              Helpers.showLoadingDialog();

              final result = await PaymentService.to.addCardWithDetails(
                name: name,
                cardNumber: cardNumber,
                expiry: expiry,
                cvv: cvv,
              );

              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              if (result.success) {
                if (sheetContext.mounted && Navigator.canPop(sheetContext)) {
                  Navigator.pop(sheetContext);
                }
                Get.snackbar(
                  'Success',
                  'Card saved successfully!',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFF161719),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                await controller.fetchSavedCards();
              } else if (!result.isCancelled && result.errorMessage != null) {
                Get.snackbar(
                  'Card Error',
                  result.errorMessage!,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
      ),
    );
  }

  Widget _buildFieldContainer({
    required Widget child,
    required bool isEditing,
  }) {
    final gradient = const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
    );

    if (isEditing) {
      return CustomPaint(
        painter: _GradientBorderPainter(
          gradient: gradient,
          strokeWidth: 1.0,
          borderRadius: 12.r,
        ),
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          child: child,
        ),
      );
    } else {
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        child: child,
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String prefixIcon,
    String? hintText,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
    required bool isEditing,
  }) {
    return _buildFieldContainer(
      isEditing: isEditing,
      child: Row(
        children: [
          SvgPicture.asset(
            prefixIcon,
            width: 20.r,
            height: 20.r,
            colorFilter: const ColorFilter.mode(
              Colors.white54,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          suffix ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField(
    TextEditingController controller, {
    String? hintText,
    required bool isEditing,
    bool readOnly = false,
  }) {
    return _buildFieldContainer(
      isEditing: isEditing,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/phone.svg',
            width: 20.r,
            height: 20.r,
            colorFilter: const ColorFilter.mode(
              Colors.white54,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),

          // Custom Styled Country Code Selector Popup (Matches Condition Dropdown Design)
          PopupMenuButton<String>(
            color: const Color(0xFF2E3036),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            elevation: 10,
            offset: Offset(0, 36.h),
            enabled: !readOnly && isEditing,
            onSelected: (String code) {
              this.controller.rxPhoneCode.value = code;
            },
            itemBuilder: (context) {
              final phoneCodes = [
                "+971 (UAE)",
                "+1 (USA)",
                "+44 (UK)",
                "+880 (BD)",
                "+966 (KSA)",
                "+974 (Qatar)",
                "+965 (Kuwait)",
                "+968 (Oman)",
                "+973 (Bahrain)",
              ];
              final currentCode = this.controller.rxPhoneCode.value;

              return phoneCodes.map((fullCode) {
                final codeOnly = fullCode.split(' ').first;
                final isSelected = currentCode == codeOnly;

                return PopupMenuItem<String>(
                  value: codeOnly,
                  height: 36.h,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3C3E46)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fullCode,
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: 16.sp,
                            color: const Color(0xFFE2B744),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            child: Row(
              children: [
                Obx(
                  () => Text(
                    this.controller.rxPhoneCode.value,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: isEditing ? Colors.white54 : Colors.white24,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Vertical divider line
          Container(
            width: 1.w,
            height: 20.h,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          SizedBox(width: 16.w),

          // Phone Input field
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveBottomSheet(BuildContext context, ProfileItem item) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFF111214,
          ), // Dark background matching bottom sheet mockup
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title: "Remove this item?" (Cormorant Garamond, bold, white, centered)
                  Center(
                    child: Text(
                      "Remove this item?",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle: "This listing will be removed from your wardrobe..." (Manrope)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "This listing will be removed from your wardrobe and won't be visible to buyers.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFF292A2D), Color(0xFF1C1D21)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.brand.toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.itemName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Text(
                                    "Listed at  ",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.sp,
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
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
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: item.imageUrl.startsWith('http')
                              ? Image.network(
                                  item.imageUrl,
                                  width: 102.r,
                                  height: 102.r,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          width: 102.r,
                                          height: 102.r,
                                          color: const Color(0xFF1E2022),
                                          child: Center(
                                            child: CustomGoldLoader(
                                              size: 24.r,
                                              strokeWidth: 2.5.r,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 102.r,
                                      height: 102.r,
                                      color: const Color(0xFF1E2022),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white30,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(item.imageUrl),
                                  width: 102.r,
                                  height: 102.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 102.r,
                                      height: 102.r,
                                      color: const Color(0xFF1E2022),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white30,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Help text
                  Center(
                    child: Text(
                      "You can relist this item anytime",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Remove Button (using custom gold button styling)
                  CustomGoldButton(
                    text: "Remove Item",
                    suffix: Icon(
                      Icons.arrow_forward,
                      size: 16.r,
                      color: Colors.black,
                    ),
                    onTap: () async {
                      Get.back();
                      await controller.deleteWardrobeItem(item);
                    },
                  ),
                  SizedBox(height: 8.h),

                  // Cancel text button
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 16.w,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF28292D), Color(0xFF1C1D20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header Badge
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFFF453A),
                    size: 26.r,
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Title
              Text(
                "Log Out",
                style: GoogleFonts.dmSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle / Confirmation message
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Logout Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Get.back();
                        Helpers.showLoadingDialog(message: "Logging out..");
                        await Get.find<AuthService>().logout();
                        Get.back(); // close loading dialog
                        Get.offAllNamed(AppRoutes.login);
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF453A), Color(0xFFD73A31)],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double strokeWidth;
  final double borderRadius;

  _GradientBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
