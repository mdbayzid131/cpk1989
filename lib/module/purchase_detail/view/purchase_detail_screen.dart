import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/module/purchase_detail/controller/purchase_detail_controller.dart';

class PurchaseDetailScreen extends GetView<PurchaseDetailController> {
  const PurchaseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final status = item.status ?? "Reserved";

    // Format price nicely
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Determine tracking steps and current progress index
    final List<Map<String, String>> steps = [
      {"title": "Reserved", "subtitle": "Item reserved for you"},
      {"title": "Collected", "subtitle": "Seller preparing pickup"},
      {"title": "Authenticating", "subtitle": "Being verified by experts"},
      {"title": "Out for delivery", "subtitle": "It's on the way"},
      {"title": "Delivered", "subtitle": "Estimated Delivery on 2 May, 2026"},
    ];

    int activeIndex = 0;
    if (status == "Reserved") {
      activeIndex = 1;
    } else if (status == "Collected") {
      activeIndex = 2;
    } else if (status == "Authenticating") {
      activeIndex = 3;
    } else if (status == "Out for delivery") {
      activeIndex = 4;
    } else if (status == "Delivered") {
      activeIndex = 5;
    }

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
          "Your Order Detail",
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Image Card
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Container(
                      height: 300.h,
                      width: double.infinity,
                      color: Colors.black,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFE2B744),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white30,
                              ),
                            ),
                      ),
                    ),
                  ),
                  // Vignette overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Play button overlay in center
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Title and Status Badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: GoogleFonts.manrope(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAF2C), // Solid gold background
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "• $status",
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // ITEM DETAILS Section Header
              Text(
                "ITEM DETAILS",
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1.0,
                ),
              ),

              SizedBox(height: 12.h),

              // ITEM DETAILS list
              _buildDetailRow("Brand", item.brand),
              _buildDescriptionDetailRow(
                "Description",
                "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
              ),
              _buildDetailRow("Suggested price", formattedPrice),
              _buildDetailRow("Condition", "Excellent"),
              _buildProofOfPurchaseRow("Proof of purchase (Optional)"),

              SizedBox(height: 28.h),

              // ITEM CURRENT STATUS Section Header
              Text(
                "ITEM CURRENT STATUS",
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1.0,
                ),
              ),

              SizedBox(height: 16.h),

              // Tracking Timeline
              VerticalStepper(
                steps: List.generate(steps.length, (index) {
                  final step = steps[index];
                  StepperStepState state;
                  if (index < activeIndex) {
                    state = StepperStepState.completed;
                  } else if (index == activeIndex) {
                    state = StepperStepState.active;
                  } else {
                    state = StepperStepState.inactive;
                  }
                  return StepperStep(
                    title: step["title"]!,
                    subtitle: step["subtitle"]!,
                    state: state,
                  );
                }),
                nodeSize: 36.r,
                activeDashedSize: 48.r,
                lineWidth: 2.w,
                stepHeight: 88.h,
                titleStyle: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                subtitleStyle: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  color: Colors.white54,
                ),
              ),

              // Payment Protection Disclaimer
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.gpp_good_outlined,
                      color: Colors.white38,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Your payment is protected until verification is complete.",
                        style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // SELLER DETAILS Section Header
              Text(
                "SELLER DETAILS",
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1.0,
                ),
              ),

              SizedBox(height: 12.h),

              // Seller capsule card
              Container(
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
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFF282A2E),
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Olivia Mendes",
                      style: GoogleFonts.manrope(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.verified,
                      color: const Color(0xFF007AFF), // Verified blue
                      size: 16.sp,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Need help footer
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      "Support",
                      "Contacting customer support...",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF1E1F22),
                      colorText: Colors.white,
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Need help? ",
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        color: Colors.white38,
                      ),
                      children: [
                        TextSpan(
                          text: "Contact support",
                          style: GoogleFonts.manrope(
                            fontSize: 13.sp,
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

              SizedBox(height: 40.h),
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
        color: Colors.white.withValues(alpha: 0.03),
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
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.manrope(
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
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                  "Bill.pdf",
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.close, color: Colors.white38, size: 12.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
