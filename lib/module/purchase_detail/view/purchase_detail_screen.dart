import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // Format price nicely
    final formattedPrice =
        "AED ${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    // Format dynamic order id (fallback to CLT-24891 if not timestamped)
    final String orderId = item.id.length > 5
        ? "CLT-${item.id.substring(item.id.length - 5)}"
        : "CLT-24891";

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
          "Order #$orderId",
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Gold spotlight rays background with luxury shopping bag
              SizedBox(
                height: 180.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sunburst rays
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PurchaseSunburstPainter(
                          rayColor: const Color(0xFFE2B744).withValues(alpha: 0.12),
                          rayCount: 36,
                        ),
                      ),
                    ),
                    // Spotlight radial glow to merge with background color
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF0F1012).withValues(alpha: 0.0),
                              const Color(0xFF0F1012),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Centered shopping bag graphic
                    const ShoppingBagWidget(),
                  ],
                ),
              ),

              // 2. Secured confirmation titles
              Center(
                child: Text(
                  "You've secured this item",
                  style: GoogleFonts.manrope(
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
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white38,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 3. Product Summary card matching checkout
              _buildProductSummaryCard(item, formattedPrice),
              SizedBox(height: 28.h),

              // 4. Delivery Status Timeline Section
              Text(
                "Delivery Status",
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),

              VerticalStepper(
                steps: List.generate(steps.length, (index) {
                  final step = steps[index];
                  StepperStepState state;
                  if (index < activeIndex) {
                    state = StepperStepState.completed;
                  } else if (index == activeIndex) {
                    // Current active stage
                    state = StepperStepState.inactive; // Keep active state visually consistent with mockup grey dots
                  } else {
                    state = StepperStepState.inactive;
                  }
                  
                  // In the mockup, the Reserved step has a checked circular node when completed.
                  // If we want exact visual matching, step 0 is completed, step 1, 2, 3 are inactive dots.
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
              SizedBox(height: 20.h),

              // 5. Verification Protected Disclaimer Pill
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gpp_good_rounded,
                        color: Colors.white54,
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Authenticity Verified. Payment protected.",
                        style: GoogleFonts.manrope(
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

              // 6. Continue Shopping CTA Button
              CustomGoldButton(
                text: "Continue Shopping",
                height: 54.h,
                suffix: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 18.sp,
                ),
                onTap: () => Get.offAllNamed(AppRoutes.bottomNavBar),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummaryCard(ProfileItem item, String formattedPrice) {
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
                    formattedPrice,
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
                      item.brand.toUpperCase() == "CHANEL" ? "Olivia Mendes" : "Seller", // Mock seller matching checkout
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
              child: item.imageUrl.startsWith('http')
                  ? Image.network(item.imageUrl, fit: BoxFit.cover)
                  : Image.asset(item.imageUrl, fit: BoxFit.cover),
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
      width: 140.w,
      height: 140.h,
      child: Image.asset(
        'assets/images/closet_bag.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// A background sunburst ray custom painter centered on the shopping bag
class PurchaseSunburstPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  PurchaseSunburstPainter({
    required this.rayColor,
    this.rayCount = 36,
  });

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
