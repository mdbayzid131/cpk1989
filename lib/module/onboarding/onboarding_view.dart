import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/onboarding/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: Stack(
        children: [
          // Background soft radial gradient glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E1A12), // faint warm gold glow in center
                    Color(0xFF0F1012), // rich deep charcoal
                  ],
                ),
              ),
            ),
          ),

          // Main page view content
          Positioned.fill(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                Center(
                  child: Text(
                    'Screen 1',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Screen 2',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Screen 3',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skip button top-left
          Obx(() {
            if (controller.currentPage.value < 2) {
              return Positioned(
                top: 50.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: controller.skip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Navigation bottom row (Indicators & Next/Enter button)
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 40.h,
            child: Obx(() {
              final isLastPage = controller.currentPage.value == 2;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = controller.currentPage.value == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: 6.w),
                        width: isActive ? 24.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF0CA),
                                    Color(0xFFD4AF37),
                                  ],
                                )
                              : null,
                          color: isActive
                              ? null
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  isLastPage ? _buildEnterButton() : _buildCircleNextButton(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Next button for page 1 & 2
  Widget _buildCircleNextButton() {
    return GestureDetector(
      onTap: controller.nextPage,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF0CA),
              Color(0xFFF9E49B),
              Color(0xFFD4AF37),
              Color(0xFFB38915),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40D4AF37),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Color(0xFF0F1012),
          size: 24,
        ),
      ),
    );
  }

  // "Enter Closete" button for page 3
  Widget _buildEnterButton() {
    return GestureDetector(
      onTap: controller.nextPage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF0CA),
              Color(0xFFF9E49B),
              Color(0xFFD4AF37),
              Color(0xFFB38915),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40D4AF37),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Closeté',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F1012),
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(Icons.arrow_forward, color: Color(0xFF0F1012), size: 18),
          ],
        ),
      ),
    );
  }

  // --- SCREEN 1: DISCOVERY & DIAGONAL MARQUEE ---
  Widget _buildScreen1() {
    return Row(
      children: [
        // Left details column
        Expanded(
          flex: 11,
          child: Padding(
            padding: EdgeInsets.only(left: 24.w, right: 8.w, top: 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: 'Scroll it.\n'),
                      const TextSpan(text: 'See it.\n'),
                      const TextSpan(text: 'Love it\n'),
                      WidgetSpan(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFFF0CA),
                                  Color(0xFFF9E49B),
                                  Color(0xFFD4AF37),
                                  Color(0xFFB38915),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Buy it',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 48.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Gold gradient underline
                            Container(
                              width: 80.w,
                              height: 3.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1.5.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF0CA),
                                    Color(0xFFD4AF37),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Luxury, from\nwomen like\nyou',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right diagonal scrolling cards column
        Expanded(
          flex: 13,
          child: ClipRect(
            child: Container(
              margin: EdgeInsets.only(top: 40.h),
              child: Transform.rotate(
                angle: 12 * math.pi / 180, // Rotate column clockwise
                child: Transform.translate(
                  offset: Offset(10.w, -60.h),
                  child: const DiagonalScrollingList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- SCREEN 2: CLOSET VIEWPORT VIEWINDER ---
  Widget _buildScreen2() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 70.h),
          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.cormorantGaramond(
                fontSize: 40.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: 'Sell in\n'),
                WidgetSpan(
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFF0CA),
                            Color(0xFFF9E49B),
                            Color(0xFFD4AF37),
                            Color(0xFFB38915),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '60 Seconds',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 80.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF0CA), Color(0xFFD4AF37)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Camera scan view container
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 120.h),
              child: const CameraScannerMockup(),
            ),
          ),

          // Subtext
          Padding(
            padding: EdgeInsets.only(bottom: 110.h, left: 16.w, right: 16.w),
            child: Text(
              'Record. Upload. We handle the rest, while you get paid.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SCREEN 3: TRUST BADGES & IMAGE ---
  Widget _buildScreen3() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 70.h),
          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.cormorantGaramond(
                fontSize: 40.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: 'Shop with\n'),
                WidgetSpan(
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFF0CA),
                            Color(0xFFF9E49B),
                            Color(0xFFD4AF37),
                            Color(0xFFB38915),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Confidence',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 80.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF0CA), Color(0xFFD4AF37)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Subtext
          Text(
            'Verified before delivery. Payment protected until you receive it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
          SizedBox(height: 30.h),

          // Handover Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/bag_handover.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),

          // Trust Badges Grid/Row
          Padding(
            padding: EdgeInsets.only(bottom: 120.h),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildTrustBadge(
                      icon: Icons.verified_outlined,
                      title: 'Authenticity\nGuaranteed',
                    ),
                  ),
                  _buildVerticalDivider(),
                  Expanded(
                    child: _buildTrustBadge(
                      icon: Icons.lock_outline,
                      title: 'Payment\nProtected',
                    ),
                  ),
                  _buildVerticalDivider(),
                  Expanded(
                    child: _buildTrustBadge(
                      icon: Icons.local_shipping_outlined,
                      title: 'Secure\nDelivery',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge({required IconData icon, required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFF0CA), Color(0xFFD4AF37)],
          ).createShader(bounds),
          child: Icon(icon, size: 28.sp, color: Colors.white),
        ),
        SizedBox(height: 10.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

// =========================================================================
// WIDGET: DiagonalScrollingList (Screen 1 Scroll View)
// =========================================================================
class DiagonalScrollingList extends StatefulWidget {
  const DiagonalScrollingList({super.key});

  @override
  State<DiagonalScrollingList> createState() => _DiagonalScrollingListState();
}

class _DiagonalScrollingListState extends State<DiagonalScrollingList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Scroll animation running infinitely
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = 180.h;
    final spacing = 16.h;
    // Total height of a single set of 3 cards
    final singleSetHeight = (cardHeight + spacing) * 3;

    final List<Map<String, dynamic>> cardData = [
      {
        'image': 'assets/images/luxury_watch.png',
        'initials': 'HR',
        'name': 'Harvey R',
        'likes': '2.4K',
        'hasGoldBorder': false,
      },
      {
        'image': 'assets/images/luxury_bag.png',
        'initials': 'MB',
        'name': 'Maren B.',
        'likes': '2.4K',
        'hasGoldBorder': true,
      },
      {
        'image': 'assets/images/luxury_heels.png',
        'initials': 'OM',
        'name': 'Olivia M.',
        'likes': '2.4K',
        'hasGoldBorder': false,
      },
    ];

    // Duplicate list items to make infinite loop seamless
    final duplicatedList = [...cardData, ...cardData];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final translationY = -_animationController.value * singleSetHeight;
        return Transform.translate(
          offset: Offset(0, translationY),
          child: Column(
            children: duplicatedList.map((data) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: ProductCard(
                  image: data['image'],
                  initials: data['initials'],
                  name: data['name'],
                  likes: data['likes'],
                  hasGoldBorder: data['hasGoldBorder'],
                  cardHeight: cardHeight,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// =========================================================================
// WIDGET: ProductCard (Screen 1 Cards)
// =========================================================================
class ProductCard extends StatelessWidget {
  final String image;
  final String initials;
  final String name;
  final String likes;
  final bool hasGoldBorder;
  final double cardHeight;

  const ProductCard({
    super.key,
    required this.image,
    required this.initials,
    required this.name,
    required this.likes,
    required this.hasGoldBorder,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: hasGoldBorder
              ? const Color(0xFFD4AF37)
              : Colors.white.withValues(alpha: 0.15),
          width: hasGoldBorder ? 1.5 : 1,
        ),
        boxShadow: hasGoldBorder
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: Stack(
          children: [
            // Product photo
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),

            // Semi-transparent dark overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Translucent play icon in center
            Center(
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // Bottom user details bar
            Positioned(
              left: 8.w,
              right: 8.w,
              bottom: 8.h,
              child: Row(
                children: [
                  // Text-based avatar (offline safe and looks premium)
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFF0CA),
                          hasGoldBorder ? const Color(0xFFD4AF37) : Colors.grey,
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),

                  // Name & Likes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 8.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              likes,
                              style: GoogleFonts.outfit(
                                fontSize: 8.sp,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET: CameraScannerMockup (Screen 2 Viewfinder & Scanner line)
// =========================================================================
class CameraScannerMockup extends StatefulWidget {
  const CameraScannerMockup({super.key});

  @override
  State<CameraScannerMockup> createState() => _CameraScannerMockupState();
}

class _CameraScannerMockupState extends State<CameraScannerMockup>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Scanline loops up and down
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Shutter outer glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        image: const DecorationImage(
          image: AssetImage('assets/images/closet_scan.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            // Dark gradient cover over camera image edges for realism
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Corner Brackets for Viewfinder
            ..._buildCornerBrackets(),

            // Moving Scanline
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: _scanController.value * 280.h + 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    children: [
                      Container(
                        height: 3.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5.r),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFD4AF37),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFFD4AF37).withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Bottom camera interface controls
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 20.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flash icon
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: const Icon(
                      Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  // Shutter Button with Pulsing Outer Glow Ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.15);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Gallery icon
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const bracketSize = 24.0;
    const borderThickness = 3.0;
    const padding = 20.0;
    final bracketColor = Colors.white.withValues(alpha: 0.85);

    return [
      // Top-Left
      Positioned(
        left: padding,
        top: padding,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: bracketColor, width: borderThickness),
              top: BorderSide(color: bracketColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Top-Right
      Positioned(
        right: padding,
        top: padding,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: bracketColor, width: borderThickness),
              top: BorderSide(color: bracketColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Bottom-Left
      Positioned(
        left: padding,
        bottom: padding + 60.h, // raised slightly to clear controls space
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: bracketColor, width: borderThickness),
              bottom: BorderSide(color: bracketColor, width: borderThickness),
            ),
          ),
        ),
      ),
      // Bottom-Right
      Positioned(
        right: padding,
        bottom: padding + 60.h,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: bracketColor, width: borderThickness),
              bottom: BorderSide(color: bracketColor, width: borderThickness),
            ),
          ),
        ),
      ),
    ];
  }
}
