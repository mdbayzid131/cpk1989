import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/config/themes/app_theme.dart';

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
                style: TextStyle(
                  fontFamily: 'Schnyder L',
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              Text(
                'See it.',
                style: TextStyle(
                  fontFamily: 'Schnyder L',
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              Text(
                'Love it',
                style: TextStyle(
                  fontFamily: 'Schnyder L',
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.goldGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  'Buy it',
                  style: TextStyle(
                    fontFamily: 'Schnyder L',
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w300,
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
                decoration: BoxDecoration(gradient: AppTheme.goldGradient),
              ),
              SizedBox(height: 24.h),
              Text(
                'Luxury, from\nwomen like\nyou',
                style: GoogleFonts.dmSans(
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

        // 3. Bottom shadow overlay to fade out cards beautifully
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 180.h,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black,
                    Colors.black,
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

class _DiagonalScrollPreviewState extends State<DiagonalScrollPreview> {
  late final PageController _pageController;
  Timer? _timer;

  // List of card data
  final List<Map<String, dynamic>> _cards = [
    {
      'imagePath': 'assets/images/luxury_watch.png',
      'username': 'Hanna R.',
      'profileImage':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
      'likes': '2.4K',
    },
    {
      'imagePath': 'assets/images/luxury_bag.png',
      'username': 'Maren B.',
      'profileImage':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
      'likes': '2.4K',
    },
    {
      'imagePath': 'assets/images/luxury_heels.png',
      'username': 'Olivia M.',
      'profileImage':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150&auto=format&fit=crop',
      'likes': '2.4K',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Start at a large index (multiple of 3) to allow infinite scrolling backwards and forwards
    _pageController = PageController(viewportFraction: 0.28, initialPage: 3000);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    // Trigger the first scroll after 1.5 seconds to feel responsive on load,
    // then continue with a periodic timer every 3 seconds.
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _scrollNext();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _scrollNext();
      });
    });
  }

  void _scrollNext() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final cardData = _cards[index % _cards.length];

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double page = _pageController.initialPage.toDouble();
            if (_pageController.hasClients &&
                _pageController.position.haveDimensions) {
              page = _pageController.page ?? page;
            }

            // Calculate distance from center
            double diff = (page - index).abs();

            // Scale and opacity effects based on distance from center
            double scale =
                1.0 -
                (diff * 0.15).clamp(
                  0.0,
                  0.3,
                ); // Center is 1.0, adjacent is 0.85
            double opacity =
                1.0 -
                (diff * 0.3).clamp(0.0, 0.5); // Center is 1.0, adjacent is 0.7

            // Dynamic gold border for the active center card
            double activeFactor = (1.0 - diff * 2.0).clamp(0.0, 1.0);
            Color borderColor = Color.lerp(
              Colors.white.withValues(alpha: 0.08),
              const Color(0xFFC98C28),
              activeFactor,
            )!;
            double borderWidth = 1.0 + (0.5 * activeFactor);

            return Center(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: _buildCard(
                    imagePath: cardData['imagePath'],
                    username: cardData['username'],
                    profileImage: cardData['profileImage'],
                    likes: cardData['likes'],
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    cardHeight: 280.h,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard({
    required String imagePath,
    required String username,
    required String profileImage,
    required String likes,
    required Color borderColor,
    required double borderWidth,
    required double cardHeight,
  }) {
    return Container(
      width: 200.w,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: borderColor, width: borderWidth),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 14.r,
                    backgroundImage: NetworkImage(profileImage),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  SizedBox(width: 8.w),

                  // Username
                  Expanded(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Heart Likes Count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        likes,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: 0.0,
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
