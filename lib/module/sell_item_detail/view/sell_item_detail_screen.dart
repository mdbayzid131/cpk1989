import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/video_preview_widget.dart';
import 'package:cpk1989/module/sell_item_detail/controller/sell_item_detail_controller.dart';

class SellItemDetailScreen extends GetView<SellItemDetailController> {
  const SellItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

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
          "Review Listing",
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
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
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                            )
                          : (item.imageUrl.endsWith('.mp4') ||
                                item.imageUrl.endsWith('.mov') ||
                                item.imageUrl.endsWith('.3gp'))
                          ? VideoPreviewWidget(
                              videoPath: item.imageUrl,
                              fit: BoxFit.cover,
                              muted: true,
                            )
                          : Image.file(
                              File(item.imageUrl),
                              fit: BoxFit.cover,
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
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAF2C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFFFFAF2C),
                        width: 1.0.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: const Color(0xFFFFAF2C),
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "AI Ready",
                          style: GoogleFonts.manrope(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFAF2C),
                          ),
                        ),
                      ],
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
                  SvgPicture.asset(
                    'assets/icons/edit pen .svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFE2B744),
                      BlendMode.srcIn,
                    ),
                    width: 18.w,
                    height: 18.h,
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

              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white38, size: 14.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      "Final verification happens after pickup.",
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
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
              _buildSellerDetailsCard(),
              SizedBox(height: 28.h),
              Text(
                "YOUR EARNINGS",
                style: GoogleFonts.manrope(
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
                child: Text(
                  "By posting, you agree to Closeté Terms & Conditions",
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _buildPostItemButton(context, item, formattedPrice),
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

  Widget _buildSellerDetailsCard() {
    return Container(
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
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150',
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
                Icons.verified_user,
                color: const Color(0xFF30D158),
                size: 14.sp,
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
              Icon(Icons.phone_outlined, color: Colors.white38, size: 16.sp),
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
    );
  }

  Widget _buildEarningsCard(double price) {
    final closetFee = price * 0.12;
    final youEarn = price * 0.88;

    final formattedPrice =
        "AED ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    final formattedFee =
        "AED ${closetFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    final formattedEarn =
        "AED ${youEarn.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formattedEarn,
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  color: const Color(0xFFE2B744),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostItemButton(
    BuildContext context,
    dynamic item,
    String formattedPrice,
  ) {
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
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        gradient: goldGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC98C28).withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(25.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Post Item",
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sparkle Widgets & Success Painter ──────────────────────────────────────
}
