import 'dart:io';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/services/payment_service.dart';
import 'package:cpk1989/core/utils/status_helper.dart';
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
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1012),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20.w,
        title: Text(
          "My Profile",
          style: GoogleFonts.dmSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
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
                  SizedBox(height: 8.h),

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
                final hasCustomPhoto = controller.hasCustomProfilePhoto;
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

                if (hasCustomPhoto && fullUrl.isNotEmpty) {
                  return Container(
                    width: 92.r,
                    height: 92.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(fullUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                // Default Initials Avatar: Gold/Yellow on Black background matching tab indicators
                final initials = controller.getUserInitials();
                return Container(
                  width: 92.r,
                  height: 92.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1012),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFAF2C),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.dmSans(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFAF2C),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
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
                      Flexible(
                        child: Text(
                          controller.rxUserName.value.isNotEmpty
                              ? controller.rxUserName.value
                              : 'Profile',
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          child: _buildStatItem("Closet Value", earningsText),
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
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
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

                  // Title: Cormorant Garamond matching Logout dialog
                  Center(
                    child: Text(
                      "Profile Photo",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // 1. Take Photo tile
                  _buildPhotoListTile(
                    icon: Icons.camera_alt_outlined,
                    iconColor: const Color(0xFFFFAF2C),
                    title: "Take Photo",
                    subtitle: "Capture a new picture using camera",
                    onTap: () {
                      Get.back();
                      controller.updateProfileImage(ImageSource.camera);
                    },
                  ),
                  SizedBox(height: 12.h),

                  // 2. Choose from Gallery tile
                  _buildPhotoListTile(
                    icon: Icons.photo_library_outlined,
                    iconColor: const Color(0xFFFFAF2C),
                    title: "Choose from Gallery",
                    subtitle: "Select an image from your photo library",
                    onTap: () {
                      Get.back();
                      controller.updateProfileImage(ImageSource.gallery);
                    },
                  ),

                  // 3. Remove Photo tile (shown only when custom photo exists)
                  Obx(() {
                    if (!controller.hasCustomProfilePhoto) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: _buildPhotoListTile(
                        icon: Icons.delete_outline_rounded,
                        iconColor: const Color(0xFFFF5252),
                        title: "Remove Photo",
                        subtitle: "Delete current photo & revert to avatar",
                        titleColor: const Color(0xFFFF5252),
                        isDestructive: true,
                        onTap: () {
                          Get.back();
                          controller.deleteProfileImage();
                        },
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),

                  // Cancel text button
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 24.w,
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
                  SizedBox(height: 4.h),
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

  Widget _buildPhotoListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFF5252).withValues(alpha: 0.08)
                : const Color(0xFF181A1E),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFFF5252).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.06),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20.r),
                ),
              ),
              SizedBox(width: 14.w),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: isDestructive
                            ? const Color(0xFFFF5252).withValues(alpha: 0.7)
                            : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDestructive
                    ? const Color(0xFFFF5252).withValues(alpha: 0.5)
                    : Colors.white24,
                size: 14.r,
              ),
            ],
          ),
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
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFFAF2C)
                    : const Color(0xFF8E8E93),
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2.h,
              width: isSelected ? 60.w : 0.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFAF2C),
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
          subtitle: "Start exploring luxury pieces",
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

            // Right product photo with multi-image carousel & dot indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 102.r,
                height: 102.r,
                child: _PurchaseCardImageCarousel(images: item.itemImages),
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

            // 2. Dark Overlay ONLY for sold items in wardrobe
            if (isWardrobe &&
                (item.isSold ||
                    StatusHelper.normalize(item.status) == 'sold' ||
                    StatusHelper.normalize(item.status) == 'delivered' ||
                    StatusHelper.normalize(item.status) == 'completed'))
              Container(color: Colors.black.withValues(alpha: 0.55)),

            // 3. Top Row: Status capsule badge & Delete squircle button (Non-overlapping & No truncation)
            // 3. Top Row: Status capsule badge & Delete squircle button (Non-overlapping & No truncation)
            Positioned(
              top: 6.h,
              left: 6.w,
              right: 6.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status capsule badge (Matches client mockup)
                  Flexible(
                    child: StatusHelper.buildItemCardBadge(
                      status: item.status,
                      isSold: item.isSold,
                      displayStatus: item.displayStatus,
                    ),
                  ),

                  // Delete squircle button (Visible on live wardrobe items only if canDelete is true)
                  if (isWardrobe &&
                      item.canDelete &&
                      (StatusHelper.normalize(item.status) == 'live' ||
                          StatusHelper.normalize(item.status) == 'available')) ...[
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => _showRemoveBottomSheet(context, item),
                      child: Container(
                        height: 24.r,
                        width: 24.r,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/delete .svg',
                            width: 12.r,
                            height: 12.r,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
              hintText: "First name",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Last Name
            _buildInputField(
              controller: controller.lastNameController,
              prefixIcon: 'assets/icons/person.svg',
              hintText: "Last name",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Location / Full Address
            _buildInputField(
              controller: controller.locationController,
              prefixIcon: 'assets/icons/location.svg',
              hintText: "Full Address",
              readOnly: !isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // Country (Fixed to UAE, read-only so nobody can type or edit)
            _buildInputField(
              controller: controller.countryController,
              prefixIcon: 'assets/icons/location.svg',
              hintText: "UAE",
              readOnly: true,
              isEditing: false,
            ),
            SizedBox(height: 12.h),

            // Phone Number
            _buildPhoneInputField(
              controller.phoneController,
              hintText: "Phone number",
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
            SizedBox(height: 24.h),
            _buildPayoutDetailsSection(context),
            SizedBox(height: 32.h),

            // Logout Button at the bottom of Personal Details (matching app consistency)
            CustomGoldButton(
              text: "Logout",
              suffix: Icon(
                Icons.arrow_forward,
                size: 16.r,
                color: Colors.black,
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPayoutDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "PAYOUT DETAILS",
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final isConnected = controller.rxIsPayoutConnected.value;

          if (isConnected) {
            return Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: const Color(0xFF131416),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stripe Logo
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          "stripe",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF635BFF),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 18.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Stripe",
                              style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Connected account",
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                color: const Color(0xFF8E9096),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              controller.rxUserName.value.isNotEmpty
                                  ? controller.rxUserName.value
                                  : "Connected Account",
                              style: GoogleFonts.dmSans(
                                fontSize: 14.5.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  // Payout Details Verified Pill Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A745).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: const Color(0xFF28A745),
                          size: 15.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          "Payout Details Verified",
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF28A745),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color(0xFF2B2D32),
                  Color(0xFF1C1D20),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clean credit card icon matching Figma
                SvgPicture.string(
                  '''<svg width="48" height="34" viewBox="0 0 48 34" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="48" height="34" rx="6" fill="#3D4046"/>
<rect y="7" width="48" height="6" fill="#202226"/>
<rect x="7" y="19" width="10" height="7" rx="2" fill="#202226"/>
</svg>''',
                  width: 48.r,
                  height: 34.r,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Payout Details",
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    "Complete your one-time payout setup to receive payments once your items have been sold and delivered.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF9EA0A5),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => controller.startStripeConnectOnboarding(),
                  child: Text(
                    "+ Complete payout setup",
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5.sp,
                      color: const Color(0xFFFFAF2C),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFFFAF2C),
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3037).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xFF9EA0A5),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          "We cannot collect your item or arrange delivery until this step has been completed.",
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: const Color(0xFF9EA0A5),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
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
                    "+ Add a new card",
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
        SizedBox(height: 12.h),
        Obx(() {
          final cards = controller.rxSavedCards;
          if (cards.isEmpty) {
            return Container(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 20.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color(0xFF2B2D32),
                    Color(0xFF1C1D20),
                  ],
                ),
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
                    '''<svg width="48" height="34" viewBox="0 0 48 34" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="48" height="34" rx="6" fill="#3D4046"/>
<rect y="7" width="48" height="6" fill="#202226"/>
<rect x="7" y="19" width="10" height="7" rx="2" fill="#202226"/>
</svg>''',
                    width: 48.r,
                    height: 34.r,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No saved cards",
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      "Add a payment method to make secure purchases",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5.sp,
                        color: const Color(0xFF9EA0A5),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => _showAddCardBottomSheet(context),
                    child: Text(
                      "+ Add payment method",
                      style: GoogleFonts.dmSans(
                        fontSize: 14.5.sp,
                        color: const Color(0xFFFFAF2C),
                        fontWeight: FontWeight.w600,
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
                final brandLower = card.brand.toLowerCase();
                final brandName = card.brand.isNotEmpty
                    ? (card.brand[0].toUpperCase() +
                        card.brand.substring(1).toLowerCase())
                    : "Card";
                final digitsOnly =
                    card.maskedNumber.replaceAll(RegExp(r'[^0-9]'), '');
                final last4 = card.last4.isNotEmpty
                    ? card.last4
                    : (digitsOnly.length >= 4
                        ? digitsOnly.substring(digitsOnly.length - 4)
                        : (digitsOnly.isNotEmpty ? digitsOnly : '4242'));
                final formattedCardNumber = "**** **** **** $last4";

                String expiryDisplay = card.expiry;
                if (expiryDisplay.isNotEmpty &&
                    !expiryDisplay.toLowerCase().startsWith('exp')) {
                  expiryDisplay = "Exp $expiryDisplay";
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131416),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCardLogo(brandLower),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  brandName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  formattedCardNumber,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF8E9096),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (expiryDisplay.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Text(
                              expiryDisplay,
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                color: const Color(0xFF8E9096),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF28A745).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: const Color(0xFF28A745),
                              size: 15.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Verified for payments",
                              style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                color: const Color(0xFF28A745),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
        width: 46.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: const Color(0xFF0057B8),
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "VISA",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 13.sp,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      // Mastercard / generic card overlapping circles
      return Container(
        width: 46.w,
        height: 32.h,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.r,
              height: 18.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: Offset(-7.w, 0),
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAddCardBottomSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
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
              FocusScope.of(sheetContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
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
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
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
    ).then((_) {
      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    });
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

          /*
          // -----------------------------------------------------------------
          // FUTURE INTERNATIONAL SUPPORT: Uncomment below for phone code menu
          // -----------------------------------------------------------------
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
          */

          // Fixed UAE Phone Code (+971)
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
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
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

                  // Title: "Log Out?" (Cormorant Garamond, bold, white, centered)
                  Center(
                    child: Text(
                      "Log Out?",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle (DM Sans)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "Are you sure you want to log out of your account?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // CTA Gold Button
                  CustomGoldButton(
                    text: "Log Out",
                    suffix: Icon(
                      Icons.arrow_forward,
                      size: 16.r,
                      color: Colors.black,
                    ),
                    onTap: () async {
                      Get.back();
                      Helpers.showLoadingDialog(message: "Logging out..");
                      await Get.find<AuthService>().logout();
                      Get.back(); // close loading dialog
                      Get.offAllNamed(AppRoutes.login);
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

class _PurchaseCardImageCarousel extends StatefulWidget {
  final List<String> images;
  const _PurchaseCardImageCarousel({required this.images});

  @override
  State<_PurchaseCardImageCarousel> createState() =>
      _PurchaseCardImageCarouselState();
}

class _PurchaseCardImageCarouselState
    extends State<_PurchaseCardImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validImages = widget.images
        .where((img) => img.trim().isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return Container(
        color: const Color(0xFF1E2022),
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined, color: Colors.white30),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: validImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final img = validImages[index];
            return img.startsWith('http')
                ? Image.network(
                    img,
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
                    File(img),
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
                  );
          },
        ),
        if (validImages.length > 1)
          Positioned(
            bottom: 6.h,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPageIndicator(
                count: validImages.length,
                currentPage: _currentPage,
                isSmall: true,
                backgroundColor: const Color(0xFF282A2E).withValues(alpha: 0.9),
                activeColor: const Color(0xFFFFAF2C),
                inactiveColor: const Color(0xFF7E7E7E),
                showBorder: false,
              ),
            ),
          ),
      ],
    );
  }
}
