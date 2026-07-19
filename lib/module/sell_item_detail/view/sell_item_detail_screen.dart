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

class SellItemDetailScreen extends GetView<SellItemDetailController> {
  const SellItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final scrollController = ScrollController();

    return Obx(() {
      final isStep2 = controller.rxStep.value == 2;
      return PopScope(
        canPop: !isStep2,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (isStep2) {
            controller.rxStep.value = 1;
          }
        },
        child: Scaffold(
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
                    if (controller.rxStep.value == 2) {
                      controller.rxStep.value = 1;
                    } else {
                      Get.back();
                    }
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
          body: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
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
                                                  return const Center(
                                                    child: CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Color(0xFFE2B744)),
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

                if (controller.rxStep.value == 1) ...[
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
                      _buildConditionEditRow(),
                      _buildProofOfPurchaseEditRow(),
                      _buildOriginalPackagingRow(),
                    ],
                  ),
                  SizedBox(height: 8.h),

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
                      ),
                      _buildSellerInputRow(
                        "Location",
                        controller.sellerLocationController,
                      ),
                      _buildSellerInputRow(
                        "Country",
                        controller.sellerCountryController,
                      ),
                      _buildSellerInputRow(
                        "Phone number",
                        controller.sellerPhoneController,
                      ),
                    ],
                  ),
                  // SizedBox(height: 24.h),
                  // Center(
                  //   child: Text.rich(
                  //     TextSpan(
                  //       text: "By posting, you agree to Closeté ",
                  //       style: GoogleFonts.dmSans(
                  //         fontSize: 12.sp,
                  //         color: Colors.white38,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       children: [
                  //         const TextSpan(
                  //           text: "Terms & Conditions",
                  //           style: TextStyle(
                  //             decoration: TextDecoration.underline,
                  //             decorationColor: Colors.white38,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  SizedBox(height: 16.h),

                  _buildContinueButton(context, scrollController),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                ] else ...[
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
                      _buildReadOnlyRow("Title", controller.rxTitle.value),
                      _buildReadOnlyRow("Brand", controller.rxBrand.value),
                      _buildReadOnlyDescriptionRow(
                        "Description",
                        controller.rxDescription.value,
                      ),
                      _buildReadOnlyRow(
                        "Listing price",
                        "AED ${controller.rxPrice.value}",
                      ),
                      _buildReadOnlyRow(
                        "Condition",
                        controller.rxCondition.value,
                      ),
                      _buildReadOnlyRow(
                        "Proof of purchase",
                        controller.rxBillName.value.isNotEmpty
                            ? controller.rxBillName.value
                            : "None",
                      ),
                      _buildReadOnlyRow(
                        "Original packaging available?",
                        controller.rxOriginalPackaging.value ? "Yes" : "No",
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
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
                  _buildSellerDetailsCard(),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PAYMENT METHOD",
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white38,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Obx(() {
                        if (controller.rxHasPaymentMethod.value) {
                          return GestureDetector(
                            onTap: () =>
                                _showPaymentMethodsBottomSheet(context),
                            child: Text(
                              "Change method",
                              style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                color: const Color(0xFFFFAF2C),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFFFAF2C),
                                decorationThickness: 1.5,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentMethodCard(),
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
                  Center(
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
                            text: "Terms & Conditions",
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
                  SizedBox(height: 16.h),
                  _buildPostItemButton(context, item),
                ],
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
          Text(
            "Title",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller.titleController,
              textAlign: TextAlign.end,
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
      final currentPrice = double.tryParse(controller.rxPrice.value) ?? price;
      final closetFee = currentPrice * 0.12;
      final youEarn = currentPrice * 0.88;

      final formattedPrice =
          "AED ${currentPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
      final formattedFee =
          "AED ${closetFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
      final formattedEarn =
          "AED ${youEarn.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

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
              _buildEarningsRow("Closeté fee (12%)", formattedFee),
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
        text: "Post Item",
        suffix: Icon(
          Icons.arrow_forward_rounded,
          color: Colors.black,
          size: 18.sp,
        ),
        onTap: () {
          showCustomDippedBottomSheet(
            context: context,
            logo: Image.asset(
              'assets/icons/done Logo.png',
              width: 80.r,
              height: 80.r,
            ),
            content: _SuccessBottomSheetContent(
              item: item,
              formattedPrice: formattedPrice,
              onDismiss: () {
                Get.back(); // Pop the bottom sheet
                Get.back(); // Pop SellItemDetailScreen
                Get.back(); // Pop SellScreen (Camera)
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildBrandEditRow() {
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
          Text(
            "Brand",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller.brandController,
              textAlign: TextAlign.end,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [],
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

  Widget _buildDescriptionEditRow() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.descriptionController,
            maxLines: null,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceEditRow() {
    return Obx(() {
      final priceVal = double.tryParse(controller.rxPrice.value) ?? 0.0;
      final isHigher = priceVal > 500.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52.h,
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isHigher
                    ? const Color(0xFFFF453A)
                    : Colors.white.withValues(alpha: 0.05),
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
                Text(
                  "Listing price",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    controller: controller.priceController,
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      prefixText: "AED ",
                      prefixStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      controller.rxPrice.value = val;
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isHigher) ...[
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFFFF453A),
                    size: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "Listing price is higher than market rate",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: const Color(0xFFFF453A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildConditionEditRow() {
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                Text(
                  "Condition",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        isExpanded: true,
                        alignment: Alignment.centerRight,
                        hint: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Select condition",
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        icon: Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        dropdownColor: const Color(0xFF1C1D20),
                        borderRadius: BorderRadius.circular(12.r),
                        selectedItemBuilder: (BuildContext context) {
                          return conditions.map<Widget>((String value) {
                            return Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                value,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: conditions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.conditionController.text = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 12.h),
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
                onTap: () => controller.rxBillName.value = "Bill.pdf",
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
                      Icons.picture_as_pdf_outlined,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.rxBillName.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.rxBillName.value = "",
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

  Widget _buildReadOnlyRow(String label, String value) {
    return Container(
      height: 52.h,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyDescriptionRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerDetailsCard() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF1C1D20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  controller.rxSellerName.value,
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.verified_rounded,
                  color: const Color(0xFF007AFF),
                  size: 16.sp,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(color: Colors.white10, height: 1),
            SizedBox(height: 12.h),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/location.svg',
                  width: 18.r,
                  height: 18.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white38,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    controller.rxSellerLocation.value,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/phone.svg',
                  width: 18.r,
                  height: 18.r,
                  colorFilter: const ColorFilter.mode(
                    Colors.white38,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  controller.rxSellerPhone.value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSellerInputRow(
    String label,
    TextEditingController textController,
  ) {
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
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: textController,
              textAlign: TextAlign.end,
              enableSuggestions: false,
              autocorrect: false,
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

  Widget _buildPaymentMethodCard() {
    return Obx(() {
      if (!controller.rxHasPaymentMethod.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: const Color(0xFF1C1D20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/icons/no payment mathood.svg',
                width: 45.w,
                height: 45.h,
              ),
              SizedBox(height: 12.h),
              Text(
                "No payout method added",
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Get paid securely after your buyer\naccepts delivery.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      _showAddCardBottomSheet(context);
                    },
                    child: Text(
                      "+ Add payout method",
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        color: const Color(0xFFFFAF2C),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFFAF2C),
                        decorationThickness: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        // Render the Visa / added card view
        final selectedCard =
            controller.rxCards[controller.rxSelectedCardIndex.value];
        final type = selectedCard['type'] ?? 'Card';
        final logo = selectedCard['logo'] ?? 'visa';
        final cardNumber = selectedCard['cardNumber'] ?? '';
        final expiry = selectedCard['expiry'] ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: const Color(0xFF1C1D20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  _buildCardLogo(logo),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (cardNumber.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            cardNumber,
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (expiry.isNotEmpty)
                    Text(
                      expiry,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.white38, size: 14.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "We'll verify your card before sending payouts.\nNo funds will be charged.",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.white38,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _buildCardLogo(String logo) {
    if (logo == 'visa') {
      return Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: const Color(0xFF005BAC), // Visa blue
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          "VISA",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 12.sp,
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
          'assets/icons/master card.svg',
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

  void _showPaymentMethodsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1012),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24.w,
            24.h,
            24.w,
            MediaQuery.of(context).padding.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment method",
                    style: GoogleFonts.dmSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.0),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Box container holding methods
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: const Color(0xFF161719),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1.0,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Obx(() {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(controller.rxCards.length, (index) {
                        final card = controller.rxCards[index];
                        final type = card['type'] ?? '';
                        final logo = card['logo'] ?? '';
                        final cardNumber = card['cardNumber'] ?? '';
                        final isSelected =
                            controller.rxSelectedCardIndex.value == index;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.rxSelectedCardIndex.value = index;
                                Navigator.pop(context);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                child: Row(
                                  children: [
                                    _buildCardLogo(logo),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            type,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (cardNumber.isNotEmpty &&
                                              cardNumber != 'Card') ...[
                                            SizedBox(height: 4.h),
                                            Text(
                                              cardNumber,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 13.sp,
                                                color: Colors.white38,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Selection circle / radio indicator
                                    if (logo == 'card')
                                      Container(
                                        width: 20.r,
                                        height: 20.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white.withValues(
                                                    alpha: 0.15,
                                                  ),
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
                                      )
                                    else
                                      Container(
                                        width: 20.r,
                                        height: 20.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          border: isSelected
                                              ? null
                                              : Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.15),
                                                  width: 1.5.r,
                                                ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.black,
                                                size: 14,
                                              )
                                            : null,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < controller.rxCards.length - 1)
                              const Divider(
                                color: Colors.white10,
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        );
                      }),
                      const Divider(
                        color: Colors.white10,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddCardBottomSheet(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Add a New card",
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
          ),
        );
      },
    );
  }

  void _showAddCardBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: CustomAddCardBottomSheet(
            onAdd:
                ({
                  required name,
                  required cardNumber,
                  required expiry,
                  required cvv,
                }) {
                  final number = cardNumber;
                  final hiddenNumber = number.length > 4
                      ? "**** **** **** ${number.substring(number.length - 4)}"
                      : "**** **** **** 4526";
                  final expiryText = expiry.isNotEmpty
                      ? "Exp $expiry"
                      : "Exp 08/28";
                  final isVisa = number.startsWith('4');

                  controller.rxCards.add({
                    'type': isVisa ? 'Visa Card' : 'Master Card',
                    'logo': isVisa ? 'visa' : 'mastercard',
                    'cardNumber': hiddenNumber,
                    'expiry': expiryText,
                  });
                  controller.rxSelectedCardIndex.value =
                      controller.rxCards.length - 1;
                  controller.rxHasPaymentMethod.value = true;

                  Navigator.pop(sheetContext); // Close sheet
                },
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return CustomGoldButton(
      text: "Continue",
      suffix: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.black,
        size: 18.sp,
      ),
      onTap: () {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        controller.rxStep.value = 2;
      },
    );
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SizedBox(height: 12.h),
        Center(
          child: Text(
            "Your item is live",
            style: TextStyle(
              fontFamily: 'Schnyder L',
              fontSize: 30.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            "We'll arrange pickup and verification shortly",
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 24.h),
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
                child: item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        width: 102.r,
                        height: 102.r,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(item.imageUrl),
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
