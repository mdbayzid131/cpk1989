import 'dart:math' as math;
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/module/purchase_detail/controller/purchase_detail_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class PurchaseDetailScreen extends GetView<PurchaseDetailController> {
  const PurchaseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;
    final status = item.status ?? "Reserved";
    final String orderId = item.id.startsWith('p')
        ? "CLT-2489${item.id.substring(1)}"
        : "CLT-24891";

    // Format price nicely
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Stepper steps configuration matching the mockup
    final List<Map<String, String>> steps = [
      {"title": "Reserved", "subtitle": "Item reserved for you"},
      {"title": "Collected", "subtitle": "Picked up from seller"},
      {"title": "Authenticating", "subtitle": "Being verified by experts"},
      {"title": "Delivered", "subtitle": "On its way to you"},
    ];

    int activeIndex = 0;
    if (status == "Reserved") {
      activeIndex = 1;
    } else if (status == "Collected") {
      activeIndex = 2;
    } else if (status == "Authenticating") {
      activeIndex = 3;
    } else if (status == "Delivered") {
      activeIndex = 4;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Stack(
        children: [
          // Main scrollable content starting from top of screen
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Gold spotlight rays background with luxury shopping bag (full-screen height top container)
                  SizedBox(
                    height: 232.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Sunburst rays SVG background
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/icons/bag.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Centered shopping bag graphic
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 98.h,
                          child: const ShoppingBagWidget(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),

                  // Content underneath with standard padding
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Secured confirmation titles
                        Center(
                          child: Text(
                            "You've secured this item",
                            style: GoogleFonts.dmSans(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Center(
                          child: Text(
                            "We'll collect and verify it within 24 hours",
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // 3. Product Summary card matching checkout
                        _buildProductSummaryCard(item, formattedPrice),
                        SizedBox(height: 24.h),

                        // 4. Delivery Status Timeline Section
                        Text(
                          "Delivery Status",
                          style: GoogleFonts.dmSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gray,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
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
                            steps: List.generate(steps.length, (index) {
                              final step = steps[index];
                              StepperStepState state;
                              if (index < activeIndex) {
                                state = StepperStepState.completed;
                              } else if (index == activeIndex) {
                                state = StepperStepState.inactive;
                              } else {
                                state = StepperStepState.inactive;
                              }

                              return StepperStep(
                                title: step["title"]!,
                                subtitle: step["subtitle"]!,
                                state: state,
                              );
                            }),
                            nodeSize: 32.r,
                            activeDashedSize: 32.r,
                            lineWidth: 2.w,
                            stepHeight: 74.h,
                            titleStyle: GoogleFonts.dmSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            subtitleStyle: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // 5. Verification Protected Disclaimer Pill
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
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.gray,
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
                        SizedBox(height: 24.h),

                        // 6. Continue Shopping CTA Button
                        CustomGoldButton(
                          text: "Continue Shopping",
                          suffix: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 18.sp,
                          ),
                          onTap: () => Get.offAllNamed(AppRoutes.bottomNavBar),
                        ),
                        SizedBox(
                          height: 24.h + MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Centered Order ID
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 60.w,
            right: 60.w,
            child: Container(
              height: 40.r,
              alignment: Alignment.center,
              child: Text(
                "Order #$orderId",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: 0,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 20.w,
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
        ],
      ),
    );
  }

  Widget _buildProductSummaryCard(ProfileItem item, String formattedPrice) {
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
          color: Colors.white.withValues(alpha: 0.08),
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
                    formattedPrice,
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
                      item.brand.toUpperCase() == "CHANEL"
                          ? "Olivia Mendes"
                          : "Seller", // Mock seller matching checkout
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SvgPicture.asset(
                      'assets/icons/blue_verify-badg.svg',
                      width: 14.r,
                      height: 14.r,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Right Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: item.imageUrl.startsWith('http')
                ? Image.network(
                    item.imageUrl,
                    width: 102.r,
                    height: 102.r,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    item.imageUrl,
                    width: 102.r,
                    height: 102.r,
                    fit: BoxFit.cover,
                  ),
          ),
        ],
      ),
    );
  }
}

/// A reusable shopping bag widget rendering the luxury shopping bag asset
class ShoppingBagWidget extends StatelessWidget {
  const ShoppingBagWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110.w,
      height: 110.h,
      child: Image.asset('assets/images/closet_bag.png', fit: BoxFit.contain),
    );
  }
}

/// A background sunburst ray custom painter centered on the shopping bag
class PurchaseSunburstPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  PurchaseSunburstPainter({required this.rayColor, this.rayCount = 36});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 1.5;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          rayColor,
          rayColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2.2));

    final angleStep = (2 * math.pi) / rayCount;
    final path = Path();

    for (int i = 0; i < rayCount; i += 2) {
      final startAngle = i * angleStep;
      final endAngle = (i + 1) * angleStep;

      path.reset();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + maxRadius * math.cos(startAngle),
        center.dy + maxRadius * math.sin(startAngle),
      );
      path.lineTo(
        center.dx + maxRadius * math.cos(endAngle),
        center.dy + maxRadius * math.sin(endAngle),
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
