import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/services/auth_service.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

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

              // Screen Header (Left-aligned as shown in mockup)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  "My Profile",
                  style: GoogleFonts.dmSans(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
              CircleAvatar(
                radius: 46.r,
                backgroundColor: const Color(0xFF282A2E),
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Profile Photo',
                      'Edit photo functionality coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E1F22),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      borderRadius: 8,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  child: Container(
                    height: 24.r,
                    width: 24.r,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF282A2E,
                      ), // Dark background matching design
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.white54, width: 1.0),
                    ),
                    child: Center(
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
                ),
              ),
            ],
          ),

          SizedBox(width: 16.w),

          // Name and Stats columns
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
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.verified,
                        color: const Color(0xFF007AFF), // Verified badge blue
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Translucent Stats Container (Label on TOP, Value on BOTTOM)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildStatItem("Items Listed", "24")),
                      _buildStatDivider(),
                      Expanded(child: _buildStatItem("Purchases", "12")),
                      _buildStatDivider(),
                      Expanded(child: _buildStatItem("Closet Value", "12.2k")),
                    ],
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
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white38, // Grey-ish label matching mockup
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white, // White bold value matching mockup
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Obx(() {
            final selectedIndex = controller.rxSelectedIndex.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildTabItem("MY WARDROBE", 0, selectedIndex)),
                Expanded(
                  child: _buildTabItem("MY PURCHASES", 1, selectedIndex),
                ),
                Expanded(
                  child: _buildTabItem("PERSONAL DETAILS", 2, selectedIndex),
                ),
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
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFE2B744)
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
      final items = controller.rxWardrobeItems;
      if (items.isEmpty) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: Text(
            "Your wardrobe is empty.",
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
      final items = controller.rxPurchaseItems;
      if (items.isEmpty) {
        return Container(
          height: 200.h,
          alignment: Alignment.center,
          child: Text(
            "No purchase history found.",
            style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14.sp),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: items.map((item) => _buildPurchaseCard(item)).toList(),
        ),
      );
    });
  }

  Widget _buildPurchaseCard(ProfileItem item) {
    final status = item.status ?? "Delivered";
    final isDelivered = status == "Delivered";
    final statusColor = isDelivered
        ? const Color(0xFF30D158)
        : const Color(0xFFE2B744);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.purchaseDetail, arguments: item);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
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
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
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
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Price
                  Text(
                    "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16.w),

            // Right product photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                item.imageUrl,
                width: 80.r,
                height: 80.r,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80.r,
                    height: 80.r,
                    color: const Color(0xFF1E2022),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFE2B744),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80.r,
                    height: 80.r,
                    color: const Color(0xFF1E2022),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white30),
                    ),
                  );
                },
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
        "\$${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
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
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE2B744),
                            ),
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE2B744,
                    ), // Solid Gold background matching mockup
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "Sold",
                    style: GoogleFonts.dmSans(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
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
    final locationController = TextEditingController(
      text: controller.rxLocation.value,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name
          _buildInputField(
            controller: controller.firstNameController,
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: 12.h),

          // Last Name
          _buildInputField(
            controller: controller.lastNameController,
            prefixIcon: Icons.person_outline,
          ),
          SizedBox(height: 12.h),

          // Address Line 1
          _buildInputField(
            controller: controller.addressController,
            prefixIcon: Icons.location_on_outlined,
          ),
          SizedBox(height: 12.h),

          // Location
          _buildInputField(
            controller: locationController,
            prefixIcon: Icons.location_on_outlined,
            readOnly: true,
            suffix: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white54,
              size: 20.sp,
            ),
            onTap: () {
              Get.snackbar(
                'Location Selector',
                'Location editing coming soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF1E1F22),
                colorText: Colors.white,
              );
            },
          ),
          SizedBox(height: 12.h),

          // Phone Number
          _buildPhoneInputField(controller.phoneController),

          SizedBox(height: 32.h),

          // Save Changes Gold Button (matches mockup)
          CustomGoldButton(
            text: "Save Changes",
            suffix: Icon(Icons.arrow_forward, size: 16.r, color: Colors.black),
            onTap: () => controller.saveChanges(),
          ),

          SizedBox(height: 20.h),

          // Log Out button
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white30,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            onPressed: () async {
              await Get.find<AuthService>().logout();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.white30),
            label: Text(
              "Log Out",
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData prefixIcon,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(prefixIcon, color: Colors.white54, size: 20.sp),
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          suffix ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField(TextEditingController controller) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Country code selector
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Country Code',
                'Country code selection coming soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF1E1F22),
                colorText: Colors.white,
              );
            },
            child: Row(
              children: [
                Text(
                  "+971",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: Colors.white54,
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
              keyboardType: TextInputType.phone,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
            SizedBox(height: 24.h),

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
            SizedBox(height: 12.h),

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
            SizedBox(height: 20.h),

            // Product Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Text details
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
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Price Tag Capsule
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
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
                  SizedBox(width: 16.w),
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      item.imageUrl,
                      width: 76.r,
                      height: 76.r,
                      fit: BoxFit.cover,
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
            SizedBox(height: 20.h),

            // Remove Button (using custom gold button styling)
            CustomGoldButton(
              text: "Remove Item",
              suffix: Icon(
                Icons.arrow_forward,
                size: 16.r,
                color: Colors.black,
              ),
              onTap: () {
                controller.deleteItem(item.id);
                Get.back();
              },
            ),
            SizedBox(height: 12.h),

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
