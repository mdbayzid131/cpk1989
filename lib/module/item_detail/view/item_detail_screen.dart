import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/module/item_detail/controller/item_detail_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';

class ItemDetailScreen extends GetView<ItemDetailController> {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = controller.item;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Scrollable Content + Bottom Action Bar
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image Card
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(24.r),
                              ),
                              child: DetailImageSlider(
                                item: item,
                                height: 380.h,
                              ),
                            ),
                            // Vignette overlay
                            Positioned.fill(
                              child: IgnorePointer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(24.r),
                                  ),
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
                            ),
                            // Page indicator bottom left (half-cut sitting on the boundary line)
                            Positioned(
                              bottom: -9.h, // half of 18.h indicator height
                              left: 41.w,
                              child: Obx(
                                () => CustomPageIndicator(
                                  count: item.itemImages.length,
                                  currentPage: controller.rxCurrentPage.value,
                                ),
                              ),
                            ),
                            // Price tag bottom right
                            Positioned(
                              bottom: -22.h,
                              right: 16.w,
                              child: Container(
                                width: 120.w,
                                height: 48.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item.price,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30.h),

                        // Scrollable content wrapped in horizontal padding
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2. Seller Profile row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.sellerProfile,
                                        arguments: {
                                          'sellerId': item.sellerId,
                                          'userName': item.userName,
                                          'avatarUrl': item.sellerProfileImage,
                                          'isVerified': item.isVerified,
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: Colors.grey.shade900,
                                          child: ClipOval(
                                            child: Image.network(
                                              item.sellerProfileImage.isNotEmpty
                                                  ? item.sellerProfileImage
                                                  : "https://i.ibb.co/z5YHLV9/profile.png",
                                              width: 40.r,
                                              height: 40.r,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person,
                                                    color: Colors.white70,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          item.userName,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (item.isVerified) ...[
                                          SizedBox(width: 6.w),
                                          SvgPicture.asset(
                                            'assets/icons/blue_verify-badg.svg',
                                            width: 18.r,
                                            height: 18.r,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Listed price",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemName,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (item.proofOfPurchase != null &&
                                          item.proofOfPurchase!
                                              .trim()
                                              .isNotEmpty) ...[
                                        SizedBox(width: 12.w),
                                        _buildProofOfPurchaseButton(),
                                      ],
                                    ],
                                  ),

                                  SizedBox(height: 12.h),
                                  // Bullet 1
                                  Builder(
                                    builder: (context) {
                                      final desc = _getConditionDescription(
                                        item.condition,
                                      );
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "✦ ",
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12.sp,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Condition: ${item.condition}",
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 12.sp,
                                                    color: const Color(
                                                      0xFFA2A2A2,
                                                    ),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                if (desc.isNotEmpty) ...[
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    desc,
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                        0xFFA2A2A2,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 6.h),
                                  // Bullet 2
                                  Row(
                                    children: [
                                      Text(
                                        "✦ ",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12.sp,
                                          color: Colors.white60,
                                        ),
                                      ),
                                      Text(
                                        item.originalPackagingAvailable
                                            ? "Original packaging available"
                                            : "Original packaging unavailable",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12.sp,
                                          color: const Color(0xFFA2A2A2),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                ],
                              ),

                              SizedBox(height: 15.h),
                              const Divider(color: Colors.white10, height: 1),
                              SizedBox(height: 15.h),

                              // 5. Description
                              Text(
                                "DESCRIPTION",
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                item.description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.sp,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // 6. Security Assurances Grid/Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Authenticity Verified.svg',
                                      label: "Authenticity\nVerified",
                                    ),
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 36.h,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Payment Protected .svg',
                                      label: "Payment\nProtected",
                                    ),
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 36.h,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                  Expanded(
                                    child: _buildSecurityBadge(
                                      svgPath:
                                          'assets/icons/Secure Delivery.svg',
                                      label: "Secure\nDelivery",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 7. Persistent Gold Action Button at Bottom
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1012),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: CustomGoldButton(
                    text: "Secure This Item",
                    suffix: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 18,
                    ),
                    onTap: () {
                      showProcessingOverlay(context, () {
                        Get.toNamed(AppRoutes.secureCheckout, arguments: item);
                      });
                    },
                  ),
                ),
              ],
            ),

            // 2. Fixed Top Navigation Controls (Floats above layout)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomGlassButton(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  Obx(() {
                    final isFav = controller.rxIsFavorite.value;
                    return CustomGlassButton(
                      onTap: controller.toggleFavorite,
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : Colors.white,
                        size: 18.sp,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge({required String svgPath, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(svgPath, width: 24.r, height: 24.r),
        SizedBox(height: 10.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// ===================== DETAIL IMAGE SLIDER =====================
/// Stateful widget that handles horizontal manual image slider, dots, and Next arrow in ItemDetailScreen.
class DetailImageSlider extends StatefulWidget {
  final FeedItem item;
  final double height;
  const DetailImageSlider({
    super.key,
    required this.item,
    required this.height,
  });

  @override
  State<DetailImageSlider> createState() => _DetailImageSliderState();
}

class _DetailImageSliderState extends State<DetailImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = Get.find<ItemDetailController>().rxCurrentPage.value;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item.itemImages.where((img) => img.isNotEmpty).toList();

    return Stack(
      children: [
        // 1. Horizontal PageView
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: const Color(0xFF1E2022),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 48.r,
                    ),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    Get.find<ItemDetailController>().rxCurrentPage.value = index;
                  },
                  itemBuilder: (context, index) {
                    final img = images[index];
                    if (img.startsWith('http') || img.startsWith('https')) {
                      return Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E2022),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white38,
                              size: 48.r,
                            ),
                          ),
                        ),
                      );
                    } else if (img.isNotEmpty && File(img).existsSync()) {
                      return Image.file(
                        File(img),
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.0, -0.3),
                      );
                    }
                    return Container(
                      color: const Color(0xFF1E2022),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                          size: 48.r,
                        ),
                      ),
                    );
                  },
                ),
        ),

        // 2. Next arrow floating button (glassmorphic circle overlay on the right)
        Positioned(
          right: 16.w,
          top: MediaQuery.of(context).padding.top,
          bottom: 0,
          child: Center(
            child: CustomGlassButton(
              size: 44.r,
              padding: EdgeInsets.all(10.r),
              onTap: () {
                if (_pageController.hasClients) {
                  final nextPage = (_currentPage + 1) % images.length;
                  _pageController.animateToPage(
                    nextPage,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildProofOfPurchaseButton() {
  return Container(
    width: 120.w,
    height: 48.h,
    padding: EdgeInsets.all(4.r), // inner spacing
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      gradient: const LinearGradient(
        begin: Alignment(-1.0, -0.165),
        end: Alignment(1.0, 0.165),
        colors: [
          Color(0xFFAF7413),
          Color(0xFFC98C28),
          Color(0xFFE2B744),
          Color(0xFFFFED81),
          Color(0xFFE1C24E),
          Color(0xFFA06008),
        ],
        stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
      ),
    ),
    child: Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SvgPicture.string(
              '''<svg width="15" height="18" viewBox="0 0 15 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12.6504 9.65039V7.14307C12.6504 6.5299 12.6504 6.22334 12.5362 5.94769C12.422 5.67203 12.2053 5.45526 11.7717 5.02171L8.21932 1.4693C7.84514 1.09514 7.65809 0.908053 7.42627 0.797203C7.37804 0.774141 7.32869 0.753681 7.27829 0.735898C7.03597 0.650391 6.77144 0.650391 6.24224 0.650391C3.80851 0.650391 2.59162 0.650391 1.76739 1.31494C1.60087 1.4492 1.4492 1.60087 1.31494 1.76739C0.65039 2.59162 0.650391 3.80851 0.650391 6.24227V9.65039C0.650391 12.4788 0.650391 13.8931 1.52907 14.7717C2.40775 15.6504 3.82196 15.6504 6.65039 15.6504M7.40039 1.02539V1.40039C7.40039 3.52171 7.40039 4.58237 8.05942 5.24138C8.71844 5.90039 9.77909 5.90039 11.9004 5.90039H12.2754" stroke="#0F1012" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M8.90039 14.1504C9.34274 14.6055 10.5202 16.4004 11.1504 16.4004C11.7806 16.4004 12.958 14.6055 13.4004 14.1504M11.1504 15.6504L11.1504 11.1504" stroke="#0F1012" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M2.90039 8.15039H7.40039" stroke="#0F1012" stroke-width="1.3" stroke-linecap="round"/>
<path d="M2.90039 10.1191H5.99414" stroke="#0F1012" stroke-width="1.3" stroke-linecap="round"/>
</svg>
''',
              width: 18.r,
              height: 18.r,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Proof of",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              Text(
                "purchase",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _getConditionDescription(String? condition) {
  if (condition == null) return '';
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
