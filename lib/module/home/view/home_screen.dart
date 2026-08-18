import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/processing_overlay.dart';
import 'package:cpk1989/core/widgets/custom_page_indicator.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Obx(() {
        if (controller.rxItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFF0CA)),
            ),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.rxItems.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final item = controller.rxItems[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-screen background image slider
                ProductImageSlider(images: item.itemImages),

                // 2. Dark gradient overlay to ensure text readability
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Top Header Overlay (Closeté logo)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 25.h,
                  left: 20.w,
                  child: Text(
                    'Closeté',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Schnyder L',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),

                // 4. Bottom Information Overlay
                Positioned(
                  bottom:
                      95.h +
                      MediaQuery.of(context)
                          .padding
                          .bottom, // dynamically clears the bottom navigation bar height on all devices
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Info Row (Avatar + Username + Verified badge on left; Price Card right-aligned)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.sellerProfile,
                                  arguments: {
                                    'userName': item.userName,
                                    'isVerified': item.isVerified,
                                  },
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.white70,
                                                ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Flexible(
                                    child: Text(
                                      item.userName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                          ),
                          SizedBox(width: 12.w),

                          // Right Price Badge (Inline with User Name)
                          Container(
                            padding: EdgeInsets.all(9.6.r),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              item.price,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Item Details (Condition text + Item Title with View More right-aligned)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.condition,
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  controller.viewProductDetails(item);
                                },
                                child: Text(
                                  "View More",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // Trust badge (Authenticity guaranteed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/Authenticity guarante_ home page logo.svg',
                              width: 14.r,
                              height: 14.r,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Authenticity Verified. Payment Protected.",
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 13.h),

                      // Secure This Item Button (Gradient)
                      CustomGoldButton(
                        text: "Secure This Item",
                        suffix: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 18,
                        ),
                        onTap: () {
                          showProcessingOverlay(context, () {
                            // Close bottom sheet first
                            Get.back();
                            Get.toNamed(
                              AppRoutes.secureCheckout,
                              arguments: item,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}

/// ===================== PRODUCT IMAGE SLIDER =====================
/// Stateful widget that handles horizontal auto-sliding images, page indicator dots, and Next arrow.
class ProductImageSlider extends StatefulWidget {
  final List<String> images;
  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Horizontal PageView for sliding images
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final img = widget.images[index];
            if (img.startsWith('http') || img.startsWith('https')) {
              return Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white24,
                    size: 40,
                  ),
                ),
              );
            }
            return Image.asset(
              img,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            );
          },
        ),

        // 2. Next arrow floating button (glassmorphic circle overlay on the right)
        Positioned(
          right: 16.w,
          top: MediaQuery.of(context).size.height * 0.45,
          child: CustomGlassButton(
            size: 44.r,
            padding: EdgeInsets.all(10.r),
            onTap: () {
              if (_pageController.hasClients) {
                final nextPage = (_currentPage + 1) % widget.images.length;
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

        // 3. Page Indicator Dots (Pill overlay centered above bottom info bar)
        Positioned(
          bottom: 95.h + MediaQuery.of(context).padding.bottom + 190.h,
          left: 0,
          right: 0,
          child: Center(
            child: CustomPageIndicator(
              count: widget.images.length,
              currentPage: _currentPage,
            ),
          ),
        ),
      ],
    );
  }
}
