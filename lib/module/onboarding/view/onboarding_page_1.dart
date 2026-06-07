import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Text Columns on the left
        Positioned(
          left: 24.w,
          top: MediaQuery.of(context).padding.top + 100.h,
          width: 170.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scroll it.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              Text(
                'See it.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              Text(
                'Love it.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Color(0xFFAF7413),
                        Color(0xFFC98C28),
                        Color(0xFFE2B744),
                        Color(0xFFFFED81),
                        Color(0xFFE1C24E),
                        Color(0xFFA06008),
                      ],
                      stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: Text(
                  'Buy it',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Small gold horizontal accent line
              Container(
                width: 32.w,
                height: 2.h,
                color: const Color(0xFFC98C28),
              ),
              SizedBox(height: 24.h),
              Text(
                'Luxury, from\nwomen like\nyou',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        // 2. Tilted diagonal scroll area on the right
        Positioned(
          right: 30.w, // bleed off the right edge
          top: -100.h, // bleed off the top edge
          bottom: -100.h, // bleed off the bottom edge
          width: 240.w,
          child: Transform.rotate(
            angle:
                15 *
                3.14159 /
                180, // Tilted clockwise (bottom-left to top-right)
            child: const DiagonalScrollPreview(),
          ),
        ),

        // 3. Bottom fade-to-black overlay gradient to smoothly transition cards into background
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 320.h,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A0A0C).withValues(alpha: 0.0),
                    const Color(0xFF0A0A0C).withValues(alpha: 0.85),
                    const Color(0xFF0A0A0C),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DiagonalScrollPreview extends StatefulWidget {
  const DiagonalScrollPreview({super.key});

  @override
  State<DiagonalScrollPreview> createState() => _DiagonalScrollPreviewState();
}

class _DiagonalScrollPreviewState extends State<DiagonalScrollPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18), // Speed of diagonal scroll
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dimension of one card + spacing
    final cardHeight = 280.h;
    final spacing = 20.h;
    final itemTotalHeight = cardHeight + spacing;

    // We have 3 items: Watch, Bag, Heels
    // Total height of one loop is 3 * itemTotalHeight
    final loopHeight = 3 * itemTotalHeight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // topOffset goes from 0 to -loopHeight
        final topOffset = _controller.value * -loopHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // First set of 3 cards
                  _buildCard(
                    imagePath: 'assets/images/luxury_watch.png',
                    username: 'Hanna R',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_bag.png',
                    username: 'Maren B.',
                    likes: '2.4K',
                    hasGoldBorder: true,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_heels.png',
                    username: 'Olivia M.',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  // Second set of 3 cards (duplicate for seamless loop)
                  _buildCard(
                    imagePath: 'assets/images/luxury_watch.png',
                    username: 'Hanna R',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_bag.png',
                    username: 'Maren B.',
                    likes: '2.4K',
                    hasGoldBorder: true,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_heels.png',
                    username: 'Olivia M.',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  // Third set of 3 cards to ensure screen is fully covered during scroll
                  _buildCard(
                    imagePath: 'assets/images/luxury_watch.png',
                    username: 'Hanna R',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_bag.png',
                    username: 'Maren B.',
                    likes: '2.4K',
                    hasGoldBorder: true,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                  _buildCard(
                    imagePath: 'assets/images/luxury_heels.png',
                    username: 'Olivia M.',
                    likes: '2.4K',
                    hasGoldBorder: false,
                    cardHeight: cardHeight,
                    spacing: spacing,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String imagePath,
    required String username,
    required String likes,
    required bool hasGoldBorder,
    required double cardHeight,
    required double spacing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      width: 200.w,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: hasGoldBorder
            ? Border.all(color: const Color(0xFFC98C28), width: 1.5)
            : Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),

            // Subtle dark overlay to ensure text is readable
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Play Button in the absolute center
            Center(
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26.w,
                  ),
                ),
              ),
            ),

            // Bottom glassmorphic metadata info bar
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      username.substring(0, 1),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),

                  // Username
                  Expanded(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Heart Likes Count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 14.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        likes,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
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
    );
  }
}
