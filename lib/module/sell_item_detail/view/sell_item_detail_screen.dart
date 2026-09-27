import 'package:cpk1989/core/services/payment_service.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_dipped_bottom_sheet.dart';
import 'package:cpk1989/core/widgets/custom_add_card_bottom_sheet.dart';
import 'package:cpk1989/module/sell_item_detail/controller/sell_item_detail_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/core/utils/validators.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/config/env_config.dart';

class SellItemDetailScreen extends GetView<SellItemDetailController> {
  const SellItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final scrollController = ScrollController();

    return Obx(() {
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
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
          title: Text(
            "Review Listing",
            style: GoogleFonts.dmSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300.h,
                  child: OverflowBox(
                    minWidth: MediaQuery.of(context).size.width,
                    maxWidth: MediaQuery.of(context).size.width,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: PageView.builder(
                            controller: controller.pageController,
                            onPageChanged: (index) {
                              controller.rxCurrentPage.value = index;
                            },
                            itemCount: item.itemImages.length,
                            itemBuilder: (context, index) {
                              final imgUrl = item.itemImages[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    color: const Color(0xFF1C1D20),
                                    child: imgUrl.startsWith('http')
                                        ? Image.network(
                                            imgUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child: CustomGoldLoader(
                                                      size: 24.r,
                                                      strokeWidth: 2.5.r,
                                                    ),
                                                  );
                                                },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white30,
                                                      ),
                                                    ),
                                          )
                                        : Image.file(
                                            File(imgUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white30,
                                                      ),
                                                    ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: -9.h,
                          child: CustomPageIndicator(
                            count: item.itemImages.length,
                            currentPage: controller.rxCurrentPage.value,
                            isSmall: false,
                            showBorder: false,
                            backgroundColor: const Color(0xFF0F1012),
                            activeColor: const Color(0xFFFFAF2C),
                            inactiveColor: const Color(0xFF7E7E7E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ITEM DETAILS",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleEditRow(),
                    _buildBrandEditRow(),
                    _buildDescriptionEditRow(),
                    _buildPriceEditRow(),
                    _buildConditionEditRow(context),
                    _buildProofOfPurchaseEditRow(),
                    _buildOriginalPackagingRow(),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.info_outline,
                      color: Colors.white38,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Final verification happens after pickup.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                SizedBox(height: 2.h),
                Text(
                  "SELLER DETAILS",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 12.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSellerInputRow(
                      "Name",
                      controller.sellerNameController,
                      rxValue: controller.rxSellerName,
                      errorMessage: "Seller name is required",
                    ),
                    _buildSellerInputRow(
                      "Location (e.g. Dubai)",
                      controller.sellerLocationController,
                      rxValue: controller.rxSellerLocation,
                      errorMessage: "Seller location is required",
                    ),
                    _buildFixedCountryField(countryName: "UAE"),
                    _buildSellerPhoneInputField(
                      context: context,
                      errorMessage: "Valid seller phone number is required",
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  "YOUR EARNINGS",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildEarningsCard(item.price),
                SizedBox(height: 24.h),
                _buildPostItemButton(context, item),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.termsAndPolicies),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "By posting, you agree to Closeté ",
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(
                            text: "Terms & Policies",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      24.h +
                      (MediaQuery.of(context).padding.bottom > 0
                          ? MediaQuery.of(context).padding.bottom
                          : 20.h),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleEditRow() {
    return Obx(() {
      final isInvalid =
          controller.rxFormSubmitted.value &&
          controller.rxTitle.value.trim().isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller.titleController,
              textAlign: TextAlign.start,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Enter title",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isInvalid)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                "Title is required",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildOriginalPackagingRow() {
    return Obx(() {
      final isChecked = controller.rxOriginalPackaging.value;
      return Container(
        height: 52.h,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.rxOriginalPackaging.value = !isChecked;
              },
              child: Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFFFAF2C) : Colors.white38,
                    width: 1.5.w,
                  ),
                  color: isChecked
                      ? const Color(0xFFFFAF2C)
                      : Colors.transparent,
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.rxOriginalPackaging.value = !isChecked;
                },
                child: Text(
                  "Original packaging available?",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsCard(double price) {
    return Obx(() {
      final double? parsedPrice = double.tryParse(
        controller.rxPrice.value.trim(),
      );
      final bool hasPrice = parsedPrice != null && parsedPrice > 0;

      final currentPrice = hasPrice ? parsedPrice : 0.0;
      final closetFee = currentPrice * EnvConfig.feeRate;
      final youEarn = currentPrice * EnvConfig.sellerRate;

      final formattedPrice = hasPrice
          ? "AED ${currentPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
          : "-";
      final formattedFee = hasPrice
          ? "AED ${closetFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
          : "-";
      final formattedEarn = hasPrice
          ? "AED ${youEarn.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"
          : "-";

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF1C1D20), Color(0xFF2B2D32)],
          ),
        ),
        padding: EdgeInsets.all(1.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
          ),
          child: Column(
            children: [
              _buildEarningsRow("Listing price", formattedPrice),
              SizedBox(height: 8.h),
              _buildEarningsRow(EnvConfig.feeLabel, formattedFee),
              SizedBox(height: 10.h),
              const Divider(color: Colors.white10),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "You'll Earn",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: const Color(0xFFFFAF2C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formattedEarn,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFAF2C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEarningsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPostItemButton(BuildContext context, dynamic item) {
    return Obx(() {
      final priceVal = double.tryParse(controller.rxPrice.value) ?? item.price;
      final formattedPrice =
          "AED ${priceVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

      return CustomGoldButton(
        text: "Submit Item",
        suffix: Icon(
          Icons.arrow_forward_rounded,
          color: Colors.black,
          size: 18.sp,
        ),
        onTap: () async {
          final success = await controller.postProductListing();
          if (success && context.mounted) {
            if (Get.isRegistered<ProfileController>()) {
              final profileController = Get.find<ProfileController>();
              profileController.fetchUserProfile();
              profileController.fetchMyWardrobe();
              profileController.fetchProfileStats();
            }
            showCustomDippedBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              canPop: false,
              logo: Image.asset(
                'assets/icons/done Logo.png',
                width: 80.r,
                height: 80.r,
              ),
              content: _SuccessBottomSheetContent(
                item: item,
                formattedPrice: formattedPrice,
                onDismiss: () {
                  if (Get.isRegistered<ProfileController>()) {
                    final profileController = Get.find<ProfileController>();
                    profileController.fetchUserProfile();
                    profileController.fetchMyWardrobe();
                    profileController.fetchProfileStats();
                  }
                  Get.back(); // Pop the bottom sheet
                  Get.back(); // Pop SellItemDetailScreen
                  Get.back(); // Pop SellScreen (Camera)
                },
              ),
            );
          }
        },
      );
    });
  }

  Widget _buildBrandEditRow() {
    return Obx(() {
      final isInvalid =
          controller.rxFormSubmitted.value &&
          controller.rxBrand.value.trim().isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller.brandController,
              textAlign: TextAlign.start,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [],
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Enter brand",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isInvalid)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                "Brand is required",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDescriptionEditRow() {
    return Obx(() {
      final isInvalid =
          controller.rxFormSubmitted.value &&
          controller.rxDescription.value.trim().isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            child: TextField(
              controller: controller.descriptionController,
              maxLines: null,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              textAlign: TextAlign.start,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Enter description...",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isInvalid)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                "Description is required",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildPriceEditRow() {
    return Obx(() {
      final isPriceEmpty = controller.rxPrice.value.trim().isEmpty;
      final isInvalidAmount =
          (double.tryParse(controller.rxPrice.value.trim()) ?? 0) <= 0;
      final isInvalid =
          controller.rxFormSubmitted.value && (isPriceEmpty || isInvalidAmount);
      final errorMsg = isPriceEmpty
          ? "Listing price is required"
          : "Please enter a valid listing price";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller.priceController,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Listing price AED",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
                prefixText: controller.rxPrice.value.trim().isNotEmpty
                    ? "AED "
                    : null,
                prefixStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                controller.rxPrice.value = val;
              },
            ),
          ),
          if (isInvalid)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                errorMsg,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildConditionEditRow(BuildContext context) {
    final List<String> conditions = [
      'New with Tags',
      'Like New',
      'Excellent',
      'Very Good',
      'Good',
      'Fair',
    ];

    return Obx(() {
      final currentCondition = controller.rxCondition.value;
      final dropdownValue = conditions.contains(currentCondition)
          ? currentCondition
          : null;
      final description = _getConditionDescription(currentCondition);
      final isInvalid =
          controller.rxFormSubmitted.value &&
          (currentCondition.trim().isEmpty ||
              currentCondition == "Select condition");

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(
              bottom: (description.isNotEmpty || isInvalid) ? 4.h : 8.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Condition",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 155.w,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      onOpened: () => FocusScope.of(context).unfocus(),
                      offset: Offset(16.w, 20.h),
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
                              width: 155.w,
                              height: 213.h,
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
                                  for (
                                    int i = 0;
                                    i < conditions.length;
                                    i++
                                  ) ...[
                                    if (i > 0) SizedBox(height: 5.h),
                                    Builder(
                                      builder: (context) {
                                        final cond = conditions[i];
                                        final isSelected =
                                            cond == currentCondition;
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            controller
                                                    .conditionController
                                                    .text =
                                                cond;
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: 135.w,
                                            height: 28.h,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                              top: 5.h,
                                              bottom: 5.h,
                                              left: 8.w,
                                              right: 8.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF3C3E46)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              cond,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                height: 1.0,
                                                letterSpacing: 0.0,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              dropdownValue ?? "Select condition",
                              textAlign: TextAlign.end,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                color: dropdownValue != null
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(
                left: 4.w,
                right: 4.w,
                bottom: isInvalid ? 4.h : 12.h,
              ),
              child: Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: const Color(0xFFA2A2A2),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          if (isInvalid)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                "Please select item condition",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  String _getConditionDescription(String condition) {
    switch (condition) {
      case 'New with Tags':
        return 'Brand new, never used, original tags attached';
      case 'Like New':
        return 'Excellent condition with little to no visible signs of wear';
      case 'Excellent':
        return 'Light signs of use, very well maintained';
      case 'Very Good':
        return 'Noticeable but minor wear, no significant defects';
      case 'Good':
        return 'Visible signs of wear but fully functional and presentable';
      case 'Fair':
        return 'Heavy wear or imperfections, reflected in the price';
      default:
        return '';
    }
  }

  Widget _buildProofOfPurchaseEditRow() {
    return Container(
      height: 52.h,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Proof of purchase(Optional)",
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            if (controller.rxBillName.value.isEmpty) {
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.pickBillFile();
                },
                child: Text(
                  "Upload Bill",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: const Color(0xFFFFAF2C),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFFFAF2C),
                    decorationThickness: 1.5,
                  ),
                ),
              );
            } else {
              final isPdf = controller.rxBillName.value.toLowerCase().endsWith(
                '.pdf',
              );
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        controller.rxBillName.value,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        controller.rxBillName.value = "";
                        controller.rxBillPath.value = "";
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white38,
                        size: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // Widget _buildReadOnlyRow(String label, String value) {
  //   return Container(
  //     height: 52.h,
  //     margin: EdgeInsets.only(bottom: 8.h),
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.r),
  //       border: Border.all(
  //         color: Colors.white.withValues(alpha: 0.05),
  //         width: 1.0,
  //       ),
  //       gradient: const LinearGradient(
  //         begin: Alignment.centerRight,
  //         end: Alignment.centerLeft,
  //         colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: GoogleFonts.dmSans(
  //             fontSize: 14.sp,
  //             color: Colors.white38,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         SizedBox(width: 16.w),
  //         Expanded(
  //           child: Text(
  //             value,
  //             textAlign: TextAlign.end,
  //             style: GoogleFonts.dmSans(
  //               fontSize: 14.sp,
  //               color: Colors.white,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildReadOnlyDescriptionRow(String label, String value) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 8.h),
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.r),
  //       border: Border.all(
  //         color: Colors.white.withValues(alpha: 0.05),
  //         width: 1.0,
  //       ),
  //       gradient: const LinearGradient(
  //         begin: Alignment.centerRight,
  //         end: Alignment.centerLeft,
  //         colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: GoogleFonts.dmSans(
  //             fontSize: 13.sp,
  //             color: Colors.white38,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         SizedBox(height: 8.h),
  //         Text(
  //           value,
  //           style: GoogleFonts.dmSans(
  //             fontSize: 14.sp,
  //             color: Colors.white,
  //             height: 1.4,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSellerDetailsCard() {
  //   return Obx(() {
  //     return Container(
  //       padding: EdgeInsets.all(16.w),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16.r),
  //         color: const Color(0xFF1C1D20),
  //         border: Border.all(
  //           color: Colors.white.withValues(alpha: 0.05),
  //           width: 1.0,
  //         ),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               CircleAvatar(
  //                 radius: 20.r,
  //                 backgroundImage: const NetworkImage(
  //                   'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
  //                 ),
  //               ),
  //               SizedBox(width: 12.w),
  //               Text(
  //                 controller.rxSellerName.value,
  //                 style: GoogleFonts.dmSans(
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               SizedBox(width: 6.w),
  //               Icon(
  //                 Icons.verified_rounded,
  //                 color: const Color(0xFF007AFF),
  //                 size: 16.sp,
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12.h),
  //           const Divider(color: Colors.white10, height: 1),
  //           SizedBox(height: 12.h),
  //           Row(
  //             children: [
  //               SvgPicture.asset(
  //                 'assets/icons/location.svg',
  //                 width: 18.r,
  //                 height: 18.r,
  //                 colorFilter: const ColorFilter.mode(
  //                   Colors.white38,
  //                   BlendMode.srcIn,
  //                 ),
  //               ),
  //               SizedBox(width: 10.w),
  //               Expanded(
  //                 child: Text(
  //                   controller.rxSellerLocation.value,
  //                   style: GoogleFonts.dmSans(
  //                     fontSize: 14.sp,
  //                     color: Colors.white70,
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 10.h),
  //           Row(
  //             children: [
  //               SvgPicture.asset(
  //                 'assets/icons/phone.svg',
  //                 width: 18.r,
  //                 height: 18.r,
  //                 colorFilter: const ColorFilter.mode(
  //                   Colors.white38,
  //                   BlendMode.srcIn,
  //                 ),
  //               ),
  //               SizedBox(width: 10.w),
  //               Text(
  //                 controller.rxSellerPhone.value,
  //                 style: GoogleFonts.dmSans(
  //                   fontSize: 14.sp,
  //                   color: Colors.white70,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  Widget _buildSellerInputRow(
    String hintText,
    TextEditingController textController, {
    RxString? rxValue,
    String? errorMessage,
    bool isPhone = false,
  }) {
    return Obx(() {
      final value = rxValue?.value ?? textController.text;
      final isInvalid =
          controller.rxFormSubmitted.value &&
          (isPhone
              ? (Validators.phone(value, message: errorMessage) != null)
              : value.trim().isEmpty);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: textController,
              textAlign: TextAlign.start,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              textInputAction: isPhone
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: isPhone
                  ? (_) => FocusManager.instance.primaryFocus?.unfocus()
                  : null,
              enableSuggestions: false,
              autocorrect: false,
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
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isInvalid && errorMessage != null)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                errorMessage,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildFixedCountryField({String countryName = "UAE"}) {
    return Container(
      height: 52.h,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Text(
        countryName,
        style: GoogleFonts.dmSans(
          fontSize: 14.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSellerPhoneInputField({
    required BuildContext context,
    String? errorMessage,
  }) {
    return Obx(() {
      final value = controller.rxSellerPhone.value;
      final isInvalid =
          controller.rxFormSubmitted.value &&
          (value.trim().isEmpty ||
              Validators.phone(controller.formattedSellerPhone) != null);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: isInvalid ? 4.h : 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Fixed UAE Phone Code (+971)
                Obx(
                  () => Text(
                    controller.rxPhoneCode.value,
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
                  width: 1,
                  height: 20.h,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                SizedBox(width: 12.w),
                // Number field
                Expanded(
                  child: TextField(
                    controller: controller.sellerPhoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
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
                        fontWeight: FontWeight.w400,
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
          if (isInvalid && errorMessage != null)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                errorMessage,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      );
    });
  }





}

class _SuccessBottomSheetContent extends StatelessWidget {
  final ProfileItem item;
  final String formattedPrice;
  final VoidCallback onDismiss;

  const _SuccessBottomSheetContent({
    required this.item,
    required this.formattedPrice,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    String brandName = item.brand.trim().isNotEmpty ? item.brand.trim() : '';
    String itemName = item.itemName.trim().isNotEmpty
        ? item.itemName.trim()
        : '';
    String imagePath = item.imageUrl;

    if (Get.isRegistered<SellItemDetailController>()) {
      final controller = Get.find<SellItemDetailController>();
      if (controller.rxBrand.value.trim().isNotEmpty) {
        brandName = controller.rxBrand.value.trim();
      }
      if (controller.rxTitle.value.trim().isNotEmpty) {
        itemName = controller.rxTitle.value.trim();
      }
      if (item.images != null && item.images!.isNotEmpty) {
        imagePath = item.images!.first;
      }
    }

    if (brandName.isEmpty) brandName = 'BRAND';
    if (itemName.isEmpty) itemName = 'Product Listing';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SizedBox(height: 12.h),
        Center(
          child: Text(
            "Listing Submitted",
            style: TextStyle(
              fontFamily: 'Schnyder L',
              fontSize: 28.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "Your listing has been received and is now under review. We’ll notify you within 24 hours.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13.5.sp,
                color: Colors.white60,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28A745).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "Pending review",
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF28A745),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      brandName.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      itemName,
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
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            formattedPrice,
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
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: 102.r,
                        height: 102.r,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imagePath),
                        width: 102.r,
                        height: 102.r,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        CustomGoldButton(
          text: "Continue Shopping",
          suffix: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.black,
            size: 16.sp,
          ),
          onTap: onDismiss,
        ),
      ],
    );
  }
}
