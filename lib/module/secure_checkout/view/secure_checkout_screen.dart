import 'dart:ui' show ImageFilter;
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/module/secure_checkout/controller/secure_checkout_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/core/widgets/custom_add_card_bottom_sheet.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/widgets/payment_error_bottom_sheet.dart';

class SecureCheckoutScreen extends GetView<SecureCheckoutController> {
  const SecureCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
          style: GoogleFonts.dmSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
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
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gray,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Please confirm your shipping information for\nthis order.",
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: AppTheme.gray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Form inputs (Location, Country, Phone number)
                  Obx(
                    () => _buildTextInputField(
                      controller: controller.locationController,
                      hintText: "Location (e.g. Dhaka)",
                      svgPath: "assets/icons/location.svg",
                      errorText: controller.rxLocationError.value,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final currentCountry = controller.rxLocation.value;
                    final countries = [
                      "UAE",
                      "Bangladesh",
                      "Saudi Arabia",
                      "Qatar",
                      "Kuwait",
                      "USA",
                      "UK",
                      "Oman",
                      "Bahrain",
                    ];
                    if (currentCountry.isNotEmpty &&
                        !countries.contains(currentCountry)) {
                      countries.insert(0, currentCountry);
                    }
                    return _buildDropdownField(
                      context: context,
                      value: controller.rxLocation,
                      svgPath: "assets/icons/country.svg",
                      items: countries,
                    );
                  }),
                  SizedBox(height: 12.h),
                  Obx(
                    () => _buildPhoneInputField(
                      errorText: controller.rxPhoneError.value,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Payment Method Section Header
                  Text(
                    "Payment Method",
                    style: GoogleFonts.dmSans(
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
                          context: context,
                          id: "apple_pay",
                          label: "Apple Pay",
                          logoWidget: _buildSvgLogo(
                            "assets/icons/apple pay.svg",
                            bgColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildPaymentOptionTile(
                          context: context,
                          id: "google_pay",
                          label: "Google Pay",
                          logoWidget: _buildSvgLogo(
                            "assets/icons/google pay.svg",
                            bgColor: const Color(0xFFFFC226),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildPaymentOptionTile(
                          context: context,
                          id: "card",
                          label: "Card",
                          logoWidget: _buildSvgLogo(
                            "assets/icons/master card.svg",
                            bgColor: const Color(0xFFDA3D28),
                          ),
                          isCard: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 34.h),

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

          // Blur and dim overlay when "Add card" bottom sheet is open
          Obx(() {
            if (controller.rxIsCardSheetOpen.value) {
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(color: Colors.black.withValues(alpha: 0.45)),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildProductSummaryCard() {
    final item = controller.item;
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        top: 10.h,
        bottom: 10.h,
        right: 10.w,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF2B2C30),
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
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    item.price.startsWith('AED')
                        ? item.price
                        : "AED ${item.price}",
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
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
                  style: GoogleFonts.dmSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                // Seller Name + Verification dot
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.userName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    if (item.isVerified) ...[
                      SizedBox(width: 6.w),
                      SvgPicture.asset(
                        'assets/icons/blue_verify-badg.svg',
                        width: 14.r,
                        height: 14.r,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Right Image Stack (with small indicator overlay sitting on the bottom border)
          CheckoutImageCarousel(item: item),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    String? svgPath,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
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
              if (svgPath != null)
                SvgPicture.asset(
                  svgPath,
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20.sp,
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.dmSans(
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
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF453A),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required RxString value,
    IconData? icon,
    String? svgPath,
    required List<String> items,
  }) {
    final menuWidth = 180.w;
    final itemHeight = 36.h;
    final totalHeight = (items.length * itemHeight) + 20.h;

    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath,
              width: 20.r,
              height: 20.r,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
          else if (icon != null)
            Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = constraints.maxWidth;
                final xOffset = buttonWidth - menuWidth + 32.w;

                return Theme(
                  data: Theme.of(context).copyWith(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: PopupMenuButton<String>(
                    offset: Offset(xOffset, 24.h),
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: menuWidth,
                            height: totalHeight,
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E3036),
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < items.length; i++) ...[
                                  if (i > 0) SizedBox(height: 5.h),
                                  Builder(
                                    builder: (context) {
                                      final item = items[i];
                                      final isSelected = item == value.value;
                                      return GestureDetector(
                                        onTap: () {
                                          value.value = item;
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: itemHeight - 5.h,
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5.h,
                                            horizontal: 12.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF3C3E46)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Text(
                                            item,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    child: Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: Text(
                              value.value,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white38,
                            size: 30.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField({String? errorText}) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
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
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    items: [
                      "+971",
                      "+1",
                      "+44",
                      "+880",
                      "+966",
                      "+974",
                      "+965",
                      "+968",
                      "+973",
                    ].map((String code) {
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
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Phone number",
                    hintStyle: GoogleFonts.dmSans(
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
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF453A),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required BuildContext context,
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
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.selectPaymentMethod(id),
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    // Logo Box
                    logoWidget,
                    SizedBox(width: 12.w),
                    // Name label
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.dmSans(
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
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          width: 1.5.r,
                        ),
                      ),
                      padding: EdgeInsets.all(3.r),
                      child: isSelected
                          ? Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCard && isSelected) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Obx(() {
                final savedCards = controller.profileController.rxSavedCards;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1.h,
                    ),
                    ...List.generate(savedCards.length, (index) {
                      final card = savedCards[index];
                      final brand = card.brand;
                      final isVisa = brand.toLowerCase().contains('visa');
                      final last4 = card.last4;
                      final isCardSelected =
                          controller.rxSelectedCardId.value == card.id ||
                          (controller.rxSelectedCardId.value.isEmpty &&
                              index == 0);

                      return Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              controller.rxSelectedCardId.value = card.id;
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  _buildCardLogoBox(isVisa),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isVisa ? "Visa Card" : "Master Card",
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          "•••• •••• •••• $last4",
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 18.r,
                                    height: 18.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCardSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: isCardSelected
                                          ? null
                                          : Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              width: 1.5.r,
                                            ),
                                    ),
                                    child: isCardSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.black,
                                            size: 13,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.08),
                            height: 1.h,
                          ),
                        ],
                      );
                    }),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showAddCardBottomSheet(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          children: [
                            Text(
                              "+",
                              style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "Add a New card",
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSvgLogo(String svgPath, {required Color bgColor}) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.r),
      child: SvgPicture.asset(svgPath, fit: BoxFit.contain),
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
          SvgPicture.asset(
            'assets/icons/Authenticity guarante_ home page logo.svg',
            width: 14.r,
            height: 14.r,
            colorFilter: const ColorFilter.mode(
              Color(0xFFA2A2A2),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            "Authenticity Verified. Payment Protected.",
            style: GoogleFonts.dmSans(
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
    return CustomGoldButton(
      text: "Secure This Item",
      suffix: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.black,
        size: 18.sp,
      ),
      onTap: () async {
        if (!controller.validateDeliveryDetails()) return;

        // If payment method is card and no card added, show the bottom sheet
        if (controller.rxPaymentMethod.value == "card" &&
            controller.profileController.rxSavedCards.isEmpty) {
          _showAddCardBottomSheet(context);
          return;
        }

        controller.lastErrorMessage = null;
        ProfileItem? purchasedItem;
        await showProcessingOverlay(
          context,
          () {},
          asyncTask: () async {
            purchasedItem = await controller.processPurchase();
          },
        );

        if (purchasedItem != null) {
          Get.offNamed(AppRoutes.purchaseDetail, arguments: purchasedItem);
        } else if (controller.lastErrorMessage != null &&
            controller.lastErrorMessage!.isNotEmpty) {
          controller.showPaymentErrorDialog(
            controller.lastErrorMessage!,
            context: context,
          );
        }
      },
    );
  }

  void _showAddCardBottomSheet(BuildContext context) {
    controller.rxIsCardSheetOpen.value = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: CustomAddCardBottomSheet(
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
                    if (sheetContext.mounted &&
                        Navigator.canPop(sheetContext)) {
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
                    try {
                      await controller.profileController.fetchSavedCards();
                      if (controller
                          .profileController
                          .rxSavedCards
                          .isNotEmpty) {
                        controller.rxSelectedCardId.value =
                            controller.profileController.rxSavedCards.last.id;
                      }
                    } catch (_) {}
                  } else if (!result.isCancelled &&
                      result.errorMessage != null) {
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
      },
    ).then((_) {
      controller.rxIsCardSheetOpen.value = false;
    });
  }

  Widget _buildAgreementFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            color: Colors.white38,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: "By clicking continue, you agree to our "),
            TextSpan(
              text: "Terms & Policies.",
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.white70,
              ),
              recognizer: controller.termsRecognizer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLogoBox(bool isVisa) {
    if (isVisa) {
      return Container(
        width: 38.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: const Color(0xFF0057B8),
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "VISA",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 11.sp,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return Container(
      width: 38.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1012),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(3.r),
      child: SvgPicture.asset(
        'assets/icons/master_card_colored.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class CheckoutImageCarousel extends StatefulWidget {
  final FeedItem item;
  const CheckoutImageCarousel({super.key, required this.item});

  @override
  State<CheckoutImageCarousel> createState() => _CheckoutImageCarouselState();
}

class _CheckoutImageCarouselState extends State<CheckoutImageCarousel> {
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
    final images = widget.item.itemImages;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: SizedBox(
            width: 102.r,
            height: 102.r,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final img = images[index];
                return _buildImageItem(img);
              },
            ),
          ),
        ),
        Positioned(
          bottom: -7.h, // half of the 14.h height of the small variant
          left: 0,
          right: 0,
          child: Center(
            child: CustomPageIndicator(
              count: images.length,
              currentPage: _currentPage,
              isSmall: true,
              backgroundColor: const Color(0xFF2B2C30),
              showBorder: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(String imgPath) {
    final cleanPath = imgPath.trim();
    if (cleanPath.isEmpty) {
      return _buildFallbackPlaceholder();
    }

    String finalUrl = cleanPath;
    if (!cleanPath.startsWith('http') && !cleanPath.startsWith('assets/')) {
      try {
        final origin = Uri.parse(ApiConstants.baseUrl).origin;
        final path = cleanPath.startsWith('/') ? cleanPath : '/$cleanPath';
        finalUrl = '$origin$path';
      } catch (_) {
        finalUrl = cleanPath;
      }
    }

    if (finalUrl.startsWith('http://') || finalUrl.startsWith('https://')) {
      return Image.network(
        finalUrl,
        width: 102.r,
        height: 102.r,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 102.r,
            height: 102.r,
            color: const Color(0xFF1E1F23),
            child: Center(
              child: CustomGoldLoader(size: 20.r, strokeWidth: 2.r),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackPlaceholder(),
      );
    }

    if (finalUrl.startsWith('assets/')) {
      return Image.asset(
        finalUrl,
        width: 102.r,
        height: 102.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackPlaceholder(),
      );
    }

    return _buildFallbackPlaceholder();
  }

  Widget _buildFallbackPlaceholder() {
    return Container(
      width: 102.r,
      height: 102.r,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F23),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 28.r),
          SizedBox(height: 4.h),
          Text(
            'Luxury Item',
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
