import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/module/my_item_detail/controller/my_item_detail_controller.dart';

class MyItemDetailScreen extends GetView<MyItemDetailController> {
  const MyItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final status = item.status; // null, "Reserved", "Delivered", "Rejected"

    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Setup timeline steps based on status
    final List<StepperStep> steps = [];
    if (status == "Reserved") {
      steps.addAll(const [
        StepperStep(
          title: "Reserved",
          subtitle: "Item reserved for you",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Collected",
          subtitle: "Picked up from seller",
          state: StepperStepState.active,
        ),
        StepperStep(
          title: "Authenticating",
          subtitle: "Being verified by experts",
          state: StepperStepState.inactive,
        ),
        StepperStep(
          title: "Delivered",
          subtitle: "On its way to you",
          state: StepperStepState.inactive,
        ),
      ]);
    } else if (status == "Delivered") {
      steps.addAll(const [
        StepperStep(
          title: "Reserved",
          subtitle: "Item reserved for you",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Collected",
          subtitle: "Picked up from seller",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Authenticating",
          subtitle: "Being verified by experts",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Delivered",
          subtitle: "On its way to you",
          state: StepperStepState.completed,
        ),
      ]);
    } else if (status == "Rejected") {
      steps.addAll(const [
        StepperStep(
          title: "Reserved",
          subtitle: "Item reserved for you",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Collected",
          subtitle: "Picked up from seller",
          state: StepperStepState.completed,
        ),
        StepperStep(
          title: "Authenticating (Failed)",
          subtitle: "Being verified by experts",
          state: StepperStepState.failed,
        ),
        StepperStep(
          title: "Delivered",
          subtitle: "On its way to you",
          state: StepperStepState.failed,
        ),
      ]);
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
          "Item Detail",
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (status == null)
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Center(
                child: CustomGlassButton(
                  size: 40.r,
                  onTap: () {
                    Get.snackbar(
                      "Delete Item",
                      "Item deletion triggered...",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF1E1F22),
                      colorText: Colors.white,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/delete .svg',
                    width: 16.r,
                    height: 16.r,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
                  // Play button overlay
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
                      color: status == "Rejected"
                          ? const Color(0xFFFF453A)
                          : status == null
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFFFAF2C),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      status == null
                          ? "Not Reserved yet"
                          : status == "Rejected"
                          ? "• Rejected"
                          : "• $status",
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: status == null ? Colors.white54 : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // ITEM DETAILS Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ITEM DETAILS",
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (status == null)
                    Icon(
                      Icons.edit_outlined,
                      color: const Color(0xFFE2B744),
                      size: 18.sp,
                    ),
                ],
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

              // ONLY show timeline/buyer details/earnings when status is NOT null
              if (status != null) ...[
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

                // Stepper Timeline Tracker
                VerticalStepper(
                  steps: steps,
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

                if (status == "Rejected") ...[
                  SizedBox(height: 16.h),
                  // Red Rejection Warning card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF453A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFFF453A),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "This item didn't pass authentication",
                                style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Your item is being sent back Estimated delivery: 2-3 days",
                                style: GoogleFonts.manrope(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFFFF453A),
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 28.h),

                // BUYER DETAILS Section Header
                Text(
                  "BUYER DETAILS",
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.0,
                  ),
                ),

                SizedBox(height: 12.h),

                // Buyer details card capsule
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
                  child: Column(
                    children: [
                      Row(
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
                            "Aisha Khan",
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      const Divider(color: Colors.white10),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white38,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              "Palm Jumeirah, Building 5, Apt 1204",
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.white38,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "+971 50 123 4567",
                            style: GoogleFonts.manrope(
                              fontSize: 13.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // YOUR EARNINGS / REJECTION ACTION Section
                if (status != "Rejected") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "YOUR EARNINGS",
                        style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white38,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (status == "Delivered")
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF30D158,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF30D158),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                color: const Color(0xFF30D158),
                                size: 10.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "Payout completed",
                                style: GoogleFonts.manrope(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF30D158),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Earnings card breakdown
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildEarningsRow("Listing price", "AED 4,000"),
                        SizedBox(height: 8.h),
                        _buildEarningsRow("Closeté fee (12%)", "AED 480"),
                        SizedBox(height: 10.h),
                        const Divider(color: Colors.white10),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "You'll Earn",
                              style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "AED 3,520",
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                color: const Color(
                                  0xFFE2B744,
                                ), // Gold Earn value
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Sell Again gold button
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.r),
                      gradient: LinearGradient(
                        colors: const [
                          Color(0xFFAF7413),
                          Color(0xFFC98C28),
                          Color(0xFFE2B744),
                          Color(0xFFFFED81),
                          Color(0xFFE1C24E),
                          Color(0xFFA06008),
                        ],
                        stops: const [
                          0.0477,
                          0.1933,
                          0.3893,
                          0.5054,
                          0.6210,
                          0.9074,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.snackbar(
                            "Listing Created",
                            "Re-listing item to wardrobe...",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: const Color(0xFFD4AF37),
                            colorText: Colors.black,
                          );
                        },
                        borderRadius: BorderRadius.circular(25.r),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sell Again",
                                style: GoogleFonts.manrope(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                // bottom dynamic disclaimer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white38,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        status == "Reserved"
                            ? "Final verification happens after pickup."
                            : status == "Delivered"
                            ? "Funds have been transferred to your account"
                            : "You're not charged for this listing",
                        style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

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

  Widget _buildEarningsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
