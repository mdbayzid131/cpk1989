import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

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
                        // Circular Settings Gear Button
                        GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              "Notification Settings",
                              "Manage your notification preferences",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color(0xFF1E1E22),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E1E22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 22.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (grouped.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 54.r,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "No notifications yet",
                            style: GoogleFonts.dmSans(
                              fontSize: 16.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
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
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            18.h,
                            16.w,
                            10.h,
                          ),
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
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _buildNotificationCard(item),
                              );
                            },
                            childCount: items.length,
                          ),
                        ),
                      ),
                    ];
                  }),

                // Bottom Padding to ensure cards aren't obscured by bottom nav bar
                SliverToBoxAdapter(
                  child: SizedBox(height: 110.h),
                ),
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
          colors: [
            Color(0xFF292A2D),
            Color(0xFF1C1D21),
          ],
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
            child: Center(
              child: _buildNotificationSvgIcon(item.type),
            ),
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
    final RegExp regExp = RegExp(
      r'(AED\s?[\d,]+(\.)?)',
      caseSensitive: false,
    );

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
}
