import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/module/my_purchase_ditails/controller/my_purchase_ditails_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

class MyPurchaseDitails extends GetView<MyPurchaseDitailsController> {
  const MyPurchaseDitails({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final order = item.orderModel;
    final displayStatus = item.displayStatus;
    final isCancelled = displayStatus == 'Cancelled';

    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Build timeline steps based on displayStatus
    final String st = displayStatus;
    int currentStepIndex = 0;
    if (st == 'Reserved') {
      currentStepIndex = 0;
    } else if (st == 'Collected') {
      currentStepIndex = 1;
    } else if (st == 'Authenticating') {
      currentStepIndex = 2;
    } else if (st == 'Delivered') {
      currentStepIndex = 3;
    }

    final titles = ["Reserved", "Collected", "Authenticating", "Delivered"];
    final subtitles = [
      "Item reserved for you",
      "Picked up from seller",
      "Being verified by experts",
      "On its way to you",
    ];

    final List<StepperStep> steps = [];
    for (int i = 0; i < 4; i++) {
      StepperStepState state;
      if (i < currentStepIndex) {
        state = StepperStepState.completed;
      } else if (i == currentStepIndex) {
        state = i == 0 ? StepperStepState.completed : StepperStepState.active;
      } else {
        state = StepperStepState.inactive;
      }
      steps.add(
        StepperStep(title: titles[i], subtitle: subtitles[i], state: state),
      );
    }

    // Seller info from order
    final sellerName = order?.sellerModel?.name ?? '';

    // Product details from ProductModel
    final prod = order?.productModel;
    final description = prod?.description ?? '';
    final condition = prod?.condition ?? '';

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
          "Your Order Detail",
          style: GoogleFonts.dmSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Product Image Carousel ──────────────────────────────────
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
                                          loadingBuilder: (
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
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -9.h,
                        child: Obx(
                          () => CustomPageIndicator(
                            count: item.itemImages.length,
                            currentPage: controller.rxCurrentPage.value,
                            isSmall: false,
                            showBorder: false,
                            backgroundColor: const Color(0xFF0F1012),
                            activeColor: const Color(0xFFFFAF2C),
                            inactiveColor: const Color(0xFF7E7E7E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── ITEM DETAILS header + status badge ─────────────────────
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? Colors.red.withValues(alpha: 0.15)
                          : AppTheme.yellow,
                      borderRadius: BorderRadius.circular(10.r),
                      border: isCancelled
                          ? Border.all(
                              color: Colors.red.withValues(alpha: 0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      "• $displayStatus",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isCancelled ? Colors.redAccent : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // ── ITEM DETAILS rows ───────────────────────────────────────
              _buildDetailRow("Title", item.itemName),
              _buildDetailRow("Brand", item.brand),
              if (description.isNotEmpty)
                _buildDescriptionDetailRow("Description", description),
              _buildDetailRow("Price", formattedPrice),
              if (condition.isNotEmpty)
                _buildConditionDetailRow("Condition", condition),
              _buildProofOfPurchaseRow("Proof of purchase", prod?.proofOfPurchase),
              _buildOriginalPackagingRow(prod?.originalPackagingAvailable),

              SizedBox(height: 28.h),

              // ── CANCELLED STATE ─────────────────────────────────────────
              if (isCancelled) ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                        size: 36.r,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Order Cancelled",
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "This order was cancelled.\nYour payment will be refunded if charged.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.white54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── ACTIVE ORDER: timeline + seller ───────────────────────
              if (!isCancelled) ...[
                // ITEM CURRENT STATUS header
                Text(
                  "ITEM CURRENT STATUS",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 16.h),

                // Stepper Timeline
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161719),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: VerticalStepper(
                    steps: steps,
                    nodeSize: 26.r,
                    activeDashedSize: 26.r,
                    lineWidth: 2.w,
                    stepHeight: 52.h,
                    titleStyle: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    subtitleStyle: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.white54,
                      height: 1.1,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Authenticity pill
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
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
                            Colors.white38,
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
                  ),
                ),

                SizedBox(height: 28.h),

                // SELLER DETAILS header
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

                // Seller card - name + avatar only
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: const Color(0xFF3A3B40),
                        child: Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          sellerName.isNotEmpty ? sellerName : "Seller",
                          style: GoogleFonts.dmSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32.h),

              // Bottom Support Help Text
              GestureDetector(
                onTap: () => Helpers.openSupportEmail(),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Need help? ",
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: Colors.white54,
                      ),
                      children: [
                        TextSpan(
                          text: "Contact support",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofOfPurchaseRow(String label, String? proofUrl) {
    final hasProof = proofUrl != null && proofUrl.isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
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
          const Spacer(),
          if (hasProof)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    color: const Color(0xFFFFAF2C),
                    size: 13.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "View",
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              "N/A",
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOriginalPackagingRow(bool? available) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            "Original packaging",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            (available == true) ? "Yes" : "No",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
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
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionDetailRow(String label, String value) {
    final description = _getConditionDescription(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1.0,
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
              const Spacer(),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (description.isNotEmpty)
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
    );
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
}
