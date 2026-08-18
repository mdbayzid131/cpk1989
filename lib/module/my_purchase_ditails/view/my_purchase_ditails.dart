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

class MyPurchaseDitails extends GetView<MyPurchaseDitailsController> {
  const MyPurchaseDitails({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final status = item.status ?? "Reserved";

    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Setup timeline steps based on status
    final List<StepperStep> steps = [];
    int currentStepIndex = 0;
    if (status == "Reserved") {
      currentStepIndex = 0;
    } else if (status == "Collected") {
      currentStepIndex = 1;
    } else if (status == "Authenticating") {
      currentStepIndex = 2;
    } else if (status == "Delivered") {
      currentStepIndex = 3;
    }

    final titles = ["Reserved", "Collected", "Authenticating", "Delivered"];
    final subtitles = [
      "Item reserved for you",
      "Picked up from seller",
      "Being verified by experts",
      "On its way to you",
    ];

    for (int i = 0; i < 4; i++) {
      StepperStepState state;
      if (i <= currentStepIndex) {
        state = StepperStepState.completed;
      } else {
        state = StepperStepState.inactive;
      }
      steps.add(
        StepperStep(title: titles[i], subtitle: subtitles[i], state: state),
      );
    }

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
          physics: const ScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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

                      // Translucent Play Icon Overlay
                      // Positioned.fill(
                      //   child: Center(
                      //     child: Container(
                      //       width: 54.r,
                      //       height: 54.r,
                      //       decoration: BoxDecoration(
                      //         color: Colors.white.withValues(alpha: 0.25),
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           color: Colors.white.withValues(alpha: 0.15),
                      //           width: 1.5,
                      //         ),
                      //       ),
                      //       child: Icon(
                      //         Icons.play_arrow_rounded,
                      //         color: Colors.white,
                      //         size: 32.sp,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ITEM DETAILS Section Header
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
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "• $status",
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // ITEM DETAILS list
              _buildDetailRow("Title", item.itemName),
              _buildDetailRow("Brand", item.brand),
              _buildDescriptionDetailRow(
                "Description",
                "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
              ),
              _buildDetailRow("Suggested price", formattedPrice),
              _buildConditionDetailRow("Condition", "Excellent"),
              _buildProofOfPurchaseRow("Proof of purchase (Optional)"),
              _buildOriginalPackagingRow(),

              SizedBox(height: 28.h),

              // ITEM CURRENT STATUS Section Header
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

              // Stepper Timeline Tracker (Matching Order Confirmation UI)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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

              // Shield Secure Payment Disclaimer (Matching Order Confirmation Pill UI)
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

              // SELLER DETAILS Section Header
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

              // Seller details card capsule
              CustomPaint(
                painter: _GradientBorderPainter(
                  gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                  ),
                  strokeWidth: 1.0,
                  borderRadius: 16.r,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFF2B2D32), Color(0xFF1C1D20)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: const Color(0xFF282A2E),
                        backgroundImage: const NetworkImage(
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Olivia Mendes",
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
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
              ),

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

  Widget _buildProofOfPurchaseRow(String label) {
    return Obx(() {
      if (controller.rxBillName.value.isEmpty) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
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
              ),
            ],
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
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
              ),
            ],
          ),
        );
      }
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
