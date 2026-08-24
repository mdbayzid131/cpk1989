import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_empty_state.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: Obx(() {
          if (controller.rxIsLoading.value &&
              controller.rxNotifications.isEmpty) {
            return Center(
              child: CustomGoldLoader(size: 40.r, strokeWidth: 3.5.r),
            );
          }

          final grouped = controller.groupedNotifications;

          return RefreshIndicator(
            color: const Color(0xFFE2B744),
            backgroundColor: const Color(0xFF1E2022),
            onRefresh: () => controller.fetchNotifications(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Top Header Section (Notifications Title + Settings Button)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Notifications",
                          style: GoogleFonts.dmSans(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        // Circular Settings Gear Glass Button
                        Builder(
                          builder: (btnContext) => CustomGlassButton(
                            size: 44.r,
                            onTap: () => _showSettingsMenu(btnContext),
                            child: Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (grouped.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CustomEmptyState(
                      imagePath: 'assets/images/notifecation empty.svg',
                      imageSize: 150.r,
                      title: "No New Notifications",
                      subtitle: "We'll let you know when there's an update on\nyour purchases, listings, or account.",
                      buttonText: "Refresh",
                      onButtonTap: () => controller.fetchNotifications(),
                    ),
                  )
                else
                  ...grouped.entries.expand((entry) {
                    final dateGroup = entry.key;
                    final items = entry.value;

                    return [
                      // Date Group Header (e.g. "TODAY", "AUG 19")
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
                          child: Text(
                            dateGroup.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFEBEBF5),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                      // Notification List Items under date group
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = items[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _buildNotificationCard(item),
                            );
                          }, childCount: items.length),
                        ),
                      ),
                    ];
                  }),

                // Bottom Padding to ensure cards aren't obscured by bottom nav bar
                SliverToBoxAdapter(child: SizedBox(height: 110.h)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF292A2D), Color(0xFF1C1D21)],
          stops: [0.2161, 0.5276],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Leading SVG Icon Squircle Container
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFF323236),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(child: _buildNotificationSvgIcon(item.type)),
          ),

          SizedBox(width: 12.w),

          // 2. Main Content (Title, Timestamp, Subtitle Body)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.timeAgo,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5.h),

                // Subtitle Body with bold text for key prices/details matching screenshot
                _buildSubtitleText(item.subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSvgIcon(NotificationType type) {
    String assetPath;
    switch (type) {
      case NotificationType.orderSecured:
        assetPath = 'assets/notifecation/order_secure.svg';
        break;
      case NotificationType.itemCollected:
        assetPath = 'assets/notifecation/Item collected.svg';
        break;
      case NotificationType.itemAuthenticated:
        assetPath = 'assets/notifecation/Item authenticated.svg';
        break;
      case NotificationType.itemReserved:
        assetPath = 'assets/notifecation/item_reserved.svg';
        break;
      case NotificationType.sellerDetails:
        assetPath = 'assets/notifecation/Complete your seller details.svg';
        break;
      case NotificationType.itemSaved:
        assetPath = 'assets/notifecation/New item you saved.svg';
        break;
      case NotificationType.generic:
        assetPath = 'assets/icons/notifiction.svg';
        break;
    }

    return SvgPicture.asset(
      assetPath,
      width: 22.r,
      height: 22.r,
      fit: BoxFit.contain,
    );
  }

  Widget _buildSubtitleText(String subtitle) {
    // Parse words like "AED 3,200" or "AED 3,200." to bold them matching mockup
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'(AED\s?[\d,]+(\.)?)', caseSensitive: false);

    int start = 0;
    for (final Match match in regExp.allMatches(subtitle)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: subtitle.substring(start, match.start),
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
              height: 1.35,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEBEBF5),
            height: 1.35,
          ),
        ),
      );
      start = match.end;
    }

    if (start < subtitle.length) {
      spans.add(
        TextSpan(
          text: subtitle.substring(start),
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E8E93),
            height: 1.35,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _showSettingsMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final double menuTop = offset.dy + size.height + 8.h;
    final double menuRight = 16.w;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DismissMenu',
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            // Frosted Glass Popup Menu Container
            Positioned(
              top: menuTop,
              right: menuRight,
              width: 200.w,
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  alignment: Alignment.topRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                      child: CustomPaint(
                        painter: RRectGlassBorderPainter(
                          borderRadius: 16.r,
                          strokeWidth: 1.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF), // #FFFFFF14 fill
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Mark as all read
                                InkWell(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext).pop();
                                    controller.markAllAsRead();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/notifecation/mark.svg',
                                          width: 18.r,
                                          height: 18.r,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            "Mark as all read",
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Divider line
                                Container(
                                  height: 1.0,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),

                                // 2. Delete all
                                InkWell(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16.r),
                                    bottomRight: Radius.circular(16.r),
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext).pop();
                                    controller.deleteAllNotifications();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/notifecation/delete.svg',
                                          width: 18.r,
                                          height: 18.r,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            "Delete all",
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painter that draws a mathematically precise, crisp glass refraction border on rounded rectangles
class RRectGlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;

  RRectGlassBorderPainter({required this.borderRadius, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(
          alpha: 0.65,
        ), // Top-Left glass highlight refraction
        Colors.white.withValues(alpha: 0.08), // Subtle dim middle
        Colors.white.withValues(
          alpha: 0.55,
        ), // Bottom-Right glass highlight refraction
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = borderGradient.createShader(rect);

    canvas.drawRRect(rrect.deflate(strokeWidth / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
