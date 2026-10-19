import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized status helper for Closeté ecosystem.
/// Maps backend statuses to unified UI text, stepper steps, and colors.
class StatusHelper {
  StatusHelper._();

  /// Unified Status Badge Widget matching Figma UI
  static Widget buildStatusBadge(String? status) {
    final liveStatus = status;
    final displayStatus = getDisplayStatus(liveStatus);
    final isCancelled = isCancelledOrRefunded(liveStatus);
    final norm = normalize(liveStatus);
    final isLive = norm == 'live' || norm == 'available';
    final isSoldOrDelivered = norm == 'sold' || norm == 'delivered' || norm == 'completed';
    final isRejected = norm == 'rejected';
    final isPending = norm == 'pending_review' || norm == 'pending';

    final badgeColor = isRejected || isCancelled
        ? const Color(0xFFFF3B30)
        : isPending
            ? const Color(0xFF28A745)
            : isSoldOrDelivered
                ? const Color(0xFFFFAF2C)
                : isLive
                    ? const Color(0xFF34C759)
                    : const Color(0xFFFFAF2C);

    final contentColor = isCancelled
        ? const Color(0xFFFF3B30)
        : (isRejected || isPending)
            ? Colors.white
            : Colors.black;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(
          alpha: isCancelled ? 0.15 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: isCancelled
            ? Border.all(
                color: const Color(0xFFFF453A).withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: contentColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            displayStatus,
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Product Grid Card Status Badge matching Client Mockup
  /// - Rejected: Red background, white text
  /// - Pending review: Green background, white text
  /// - Sold: Yellow background, black text
  /// - Live: Translucent glass pill, white text "• Live"
  static Widget buildItemCardBadge({
    required String? status,
    bool isSold = false,
    String? displayStatus,
  }) {
    final normStatus = normalize(status);
    final isSoldOrDelivered = isSold ||
        normStatus == 'sold' ||
        normStatus == 'delivered' ||
        normStatus == 'completed';
    final isRejected = normStatus == 'rejected';
    final isPending = normStatus == 'pending_review' || normStatus == 'pending';
    final isLive = normStatus == 'live' || normStatus == 'available';

    Color bgColor;
    Color textColor;
    String badgeText;
    bool isGlass = false;

    if (isRejected) {
      bgColor = const Color(0xFFFF3B30); // Red
      textColor = Colors.white;
      badgeText = "Rejected";
    } else if (isPending) {
      bgColor = const Color(0xFF28A745); // Green
      textColor = Colors.white;
      badgeText = "Pending review";
    } else if (isSoldOrDelivered) {
      bgColor = const Color(0xFFFFAF2C); // Yellow
      textColor = Colors.black;
      badgeText = "Sold";
    } else if (isLive) {
      bgColor = Colors.black.withValues(alpha: 0.45);
      textColor = Colors.white;
      badgeText = "• Live";
      isGlass = true;
    } else {
      bgColor = const Color(0xFFFFAF2C);
      textColor = Colors.black;
      badgeText = displayStatus ?? getDisplayStatus(status);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: isGlass
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.8,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          badgeText,
          maxLines: 1,
          style: GoogleFonts.dmSans(
            fontSize: 9.5.sp,
            fontWeight: (isSoldOrDelivered && !isLive)
                ? FontWeight.w700
                : FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Extracts clean user-friendly filename from S3 URLs or hashed filenames
  static String cleanProofFileName(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty || rawName == "N/A") return "N/A";
    final fileName = rawName.split(RegExp(r'[/\\]')).last;
    if (fileName.contains('-')) {
      final parts = fileName.split('-');
      final lastPart = parts.last;
      if (lastPart.contains('.') && lastPart.length <= 20) {
        return lastPart;
      }
      final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      if (ext.isNotEmpty) {
        return "Bill$ext";
      }
    }
    return fileName;
  }

  /// Normalized string representation (lowercase, snake_case)
  static String normalize(String? status) {
    return (status ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  /// Order Stepper Progress (0: Reserved, 1: Collected, 2: Authenticated, 3: Dispatched, 4: Delivered)
  static int getOrderStepIndex(String? status, {List<dynamic>? statusHistory}) {
    final st = normalize(status);
    if ((st == 'cancelled' || st == 'refunded') &&
        statusHistory != null &&
        statusHistory.isNotEmpty) {
      int maxStep = 0;
      for (final h in statusHistory) {
        final hStatus = h is String
            ? h
            : (h?.status?.toString() ?? '');
        final normH = normalize(hStatus);
        if (normH != 'cancelled' && normH != 'refunded') {
          final step = getOrderStepIndex(normH);
          if (step > maxStep) {
            maxStep = step;
          }
        }
      }
      return maxStep;
    }

    switch (st) {
      case 'pending_payment':
      case 'secured':
      case 'reserved':
      case 'pending':
        return 0;
      case 'collection_pending':
      case 'awaiting_collection':
      case 'collected':
      case 'in_transit':
        return 1;
      case 'verification':
      case 'authenticating':
      case 'authenticated':
      case 'payout_processing':
        return 2;
      case 'ready_for_delivery':
      case 'dispatched':
      case 'dispatch':
      case 'out_for_delivery':
        return 3;
      case 'delivered':
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  /// Human-readable title for Order / Product status
  static String getDisplayStatus(String? status) {
    final st = normalize(status);
    switch (st) {
      case 'pending_review':
        return 'Pending Review';
      case 'live':
      case 'available':
        return 'Live';
      case 'rejected':
        return 'Rejected';
      case 'pending_payment':
      case 'secured':
      case 'reserved':
      case 'pending':
        return 'Reserved';
      case 'collection_pending':
      case 'awaiting_collection':
      case 'collected':
      case 'in_transit':
        return 'Collected';
      case 'verification':
      case 'authenticating':
      case 'authenticated':
      case 'payout_processing':
        return 'Authenticated';
      case 'ready_for_delivery':
      case 'dispatched':
      case 'dispatch':
      case 'out_for_delivery':
        return 'Dispatched';
      case 'delivered':
      case 'completed':
        return 'Delivered';
      case 'sold':
        return 'Sold';
      case 'refunded':
        return 'Refunded';
      case 'cancelled':
        return 'Cancelled';
      default:
        return st.isNotEmpty
            ? (st[0].toUpperCase() + st.substring(1).replaceAll('_', ' '))
            : 'Live';
    }
  }

  /// Checks if an item is sold or active in the order lifecycle
  static bool isOrderReservedOrSold(String? status, {bool isSold = false}) {
    if (isSold) return true;
    final st = normalize(status);
    return [
      'reserved',
      'secured',
      'sold',
      'collection_pending',
      'awaiting_collection',
      'collected',
      'in_transit',
      'verification',
      'authenticating',
      'authenticated',
      'payout_processing',
      'ready_for_delivery',
      'dispatched',
      'delivered',
      'completed',
    ].contains(st);
  }

  /// Checks if the order is in a terminal cancelled/refunded state
  static bool isCancelledOrRefunded(String? status) {
    final st = normalize(status);
    return st == 'cancelled' || st == 'refunded';
  }

  /// Status badge background color
  static Color getStatusBgColor(String? status) {
    final st = normalize(status);
    switch (st) {
      case 'live':
      case 'available':
      case 'delivered':
      case 'completed':
      case 'sold':
        return const Color(0xFF34C759); // Green
      case 'rejected':
      case 'cancelled':
      case 'refunded':
        return const Color(0xFFFF5252); // Red
      case 'pending_review':
      case 'reserved':
      case 'secured':
      case 'pending_payment':
      case 'collected':
      case 'verification':
      case 'authenticated':
      case 'dispatched':
      default:
        return const Color(0xFFFFAF2C); // Brand Gold/Yellow
    }
  }
}
