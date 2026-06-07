import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/module/secure_checkout/controller/secure_checkout_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';

class SecureCheckoutScreen extends GetView<SecureCheckoutController> {
  const SecureCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Center(
            child: CustomGlassButton(
              size: 40.r,
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
        ),
        title: Text(
          "Secure your item",
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Card
              _buildProductSummaryCard(),
              SizedBox(height: 24.h),

              // Delivery details Section Header
              Text(
                "Delivery details",
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Please confirm your shipping information for this order.",
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 16.h),

              // Form inputs
              _buildTextInputField(
                controller: controller.firstNameController,
                hintText: "Enter first name here",
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(height: 12.h),
              _buildTextInputField(
                controller: controller.lastNameController,
                hintText: "Enter last name here",
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(height: 12.h),
              _buildTextInputField(
                controller: controller.addressController,
                hintText: "Palm Jumeirah, Building 5, Apt 1204",
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 12.h),
              _buildDropdownField(
                value: controller.rxLocation,
                icon: Icons.location_on_outlined,
                items: ["Dubai, UAE", "Abu Dhabi, UAE", "Sharjah, UAE"],
              ),
              SizedBox(height: 12.h),
              _buildPhoneInputField(),
              SizedBox(height: 28.h),

              // Payment Method Section Header
              Text(
                "Payment Method",
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),

              // Payment options
              Obx(
                () => Column(
                  children: [
                    _buildPaymentOptionTile(
                      id: "apple_pay",
                      label: "Apple Pay",
                      logoWidget: _buildBrandLogo(
                        " Pay",
                        Colors.white,
                        Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildPaymentOptionTile(
                      id: "google_pay",
                      label: "Google Pay",
                      logoWidget: _buildBrandLogo(
                        "G Pay",
                        const Color(0xFFF1F3F4),
                        Colors.black,
                        textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5F6368),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildPaymentOptionTile(
                      id: "card",
                      label: "Card",
                      logoWidget: _buildCardLogo(),
                      isCard: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Security pill
              Center(child: _buildSecurityPill()),
              SizedBox(height: 20.h),

              // Secure This Item CTA Button
              _buildSecureCTAButton(context),
              SizedBox(height: 16.h),

              // Agreement text footer
              Center(child: _buildAgreementFooter()),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummaryCard() {
    final item = controller.item;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D21),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Left Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Price Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "AED ${item.price}",
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Item Name
                Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                // Seller Name + Verification dot
                Row(
                  children: [
                    Text(
                      item.userName,
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.verified_user_rounded,
                      color: const Color(0xFF007AFF),
                      size: 14.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Right Image
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.r),
              child: item.imagePath.startsWith('http')
                  ? Image.network(item.imagePath, fit: BoxFit.cover)
                  : Image.asset(item.imagePath, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161719),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildDropdownField({
    required RxString value,
    required IconData icon,
    required List<String> items,
  }) {
    return Obx(
      () => Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: const Color(0xFF161719),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value.value,
                  dropdownColor: const Color(0xFF161719),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 20.sp,
                  ),
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) value.value = val;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161719),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Code Dropdown
          Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.rxPhoneCode.value,
                dropdownColor: const Color(0xFF161719),
                icon: Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38,
                    size: 16.sp,
                  ),
                ),
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                items: ["+971", "+1", "+44", "+880"].map((String code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(code),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.rxPhoneCode.value = val;
                },
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Vertical divider line
          Container(
            width: 1,
            height: 20.h,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          SizedBox(width: 12.w),
          // Number field
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Phone number",
                hintStyle: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildPaymentOptionTile({
    required String id,
    required String label,
    required Widget logoWidget,
    bool isCard = false,
  }) {
    final isSelected = controller.rxPaymentMethod.value == id;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161719),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE2B744)
              : Colors.white.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectPaymentMethod(id),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Logo Box
                    logoWidget,
                    SizedBox(width: 16.w),
                    // Name label
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Radio indicator
                    Container(
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE2B744)
                              : Colors.white.withValues(alpha: 0.15),
                          width: isSelected ? 6.r : 1.5.r,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCard && isSelected) ...[
                  SizedBox(height: 12.h),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 1.h,
                  ),
                  SizedBox(height: 12.h),
                  // Add New card tap
                  InkWell(
                    onTap: () {
                      Get.snackbar(
                        "Add Card",
                        "Card addition simulation triggered.",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFF1C1D21),
                        colorText: Colors.white,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white70, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            "Add a New card",
                            style: GoogleFonts.manrope(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo(
    String text,
    Color bgColor,
    Color textColor, {
    TextStyle? textStyle,
  }) {
    return Container(
      width: 54.w,
      height: 34.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style:
            textStyle ??
            GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
              color: textColor,
            ),
      ),
    );
  }

  Widget _buildCardLogo() {
    // Standard mastercard style
    return Container(
      width: 54.w,
      height: 34.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEB001B), // Mastercard red
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18.r,
                  height: 18.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEB001B),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-8.w, 0),
                  child: Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFFF79E1B,
                      ).withValues(alpha: 0.8), // Orange
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white54, size: 14.sp),
          SizedBox(width: 8.w),
          Text(
            "Authenticity guaranteed. Payment protected.",
            style: GoogleFonts.manrope(
              fontSize: 11.sp,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecureCTAButton(BuildContext context) {
    final goldGradient = const LinearGradient(
      colors: [
        Color(0xFFAF7413),
        Color(0xFFC98C28),
        Color(0xFFE2B744),
        Color(0xFFFFED81),
        Color(0xFFE1C24E),
        Color(0xFFA06008),
      ],
      stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.r),
        gradient: goldGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC98C28).withValues(alpha: 0.35),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show processing dialog on Payment Page, then go to success details
            showProcessingOverlay(context, () {
              // Convert dynamic FeedItem structure to ProfileItem for routing to PurchaseDetailScreen
              final profileController = Get.find<ProfileController>();
              final profileItem = profileController.rxPurchaseItems.first;

              Get.back(); // Pop SecureCheckoutScreen
              Get.toNamed(AppRoutes.purchaseDetail, arguments: profileItem);
            });
          },
          borderRadius: BorderRadius.circular(27.r),
          child: Center(
            child: Text(
              "Secure This Item →",
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.manrope(
            fontSize: 11.sp,
            color: Colors.white38,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: "By clicking continue, you agree to our "),
            TextSpan(
              text: "Terms of service",
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Purchase Policy.",
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }
}
