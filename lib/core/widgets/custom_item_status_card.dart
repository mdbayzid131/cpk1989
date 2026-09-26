import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';
import 'package:cpk1989/core/utils/status_helper.dart';

/// A reusable custom card for displaying item/order delivery status stepper and alert details.
class CustomItemStatusCard extends StatelessWidget {
  final String? status;
  final List<dynamic>? statusHistory;
  final String? cancellationReason;
  final String? outcome;
  final bool isSeller;
  final String? headerTitle;
  final TextStyle? headerStyle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool showHeader;

  const CustomItemStatusCard({
    super.key,
    required this.status,
    this.statusHistory,
    this.cancellationReason,
    this.outcome,
    this.isSeller = false,
    this.headerTitle = "ITEM CURRENT STATUS",
    this.headerStyle,
    this.margin,
    this.padding,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = StatusHelper.isCancelledOrRefunded(status);

    final titles = const [
      "Reserved",
      "Collected",
      "Authenticating",
      "Dispatched",
      "Delivered",
    ];

    final subtitles = isSeller
        ? const [
            "Item reserved by buyer",
            "Picked up by courier",
            "Being verified by experts",
            "On its way to buyer",
            "Item delivered to buyer",
          ]
        : const [
            "Item reserved for you",
            "Picked up from seller",
            "Being verified by experts",
            "On its way to you",
            "Item delivered to you",
          ];

    // Determine failure point if cancelled/refunded
    int failedStepIndex = -1;
    if (isCancelled) {
      final reasonNorm = (cancellationReason ?? '').toLowerCase();
      final outcomeNorm = (outcome ?? '').toLowerCase();

      if (outcomeNorm == 'authentication_failed' ||
          outcomeNorm == 'counterfeit' ||
          reasonNorm.contains('verification') ||
          reasonNorm.contains('authenticat') ||
          reasonNorm.contains('mismatch') ||
          reasonNorm.contains('replica') ||
          reasonNorm.contains('fake') ||
          reasonNorm.contains('differs')) {
        failedStepIndex = 2; // Authenticating failed
      } else if (outcomeNorm == 'seller_unavailable' ||
          reasonNorm.contains('seller') ||
          reasonNorm.contains('pickup') ||
          reasonNorm.contains('collection')) {
        failedStepIndex = 1; // Collected failed
      } else if (outcomeNorm == 'buyer_changed_mind' ||
          outcomeNorm == 'buyer_refused' ||
          reasonNorm.contains('rejected') ||
          reasonNorm.contains('doorstep')) {
        failedStepIndex = 4; // Delivered failed
      } else {
        // Fallback using status history
        final maxH = StatusHelper.getOrderStepIndex(status,
            statusHistory: statusHistory);
        if (maxH >= 3) {
          failedStepIndex = 4;
        } else if (maxH == 2) {
          failedStepIndex = 3;
        } else if (maxH == 1) {
          failedStepIndex = 2;
        } else {
          failedStepIndex = 1;
        }
      }
    }

    final int currentActiveStepIndex =
        StatusHelper.getOrderStepIndex(status, statusHistory: statusHistory);

    final List<StepperStep> steps = List.generate(5, (index) {
      StepperStepState state;
      String stepTitle = titles[index];

      if (isCancelled) {
        if (index < failedStepIndex) {
          state = StepperStepState.completed;
        } else if (index == failedStepIndex) {
          state = StepperStepState.failed;
          stepTitle = "${titles[index]} (Failed)";
        } else {
          state = StepperStepState.failed;
        }
      } else {
        if (index <= currentActiveStepIndex) {
          state = StepperStepState.completed;
        } else {
          state = StepperStepState.inactive;
        }
      }

      return StepperStep(
        title: stepTitle,
        subtitle: subtitles[index],
        state: state,
      );
    });

    // Alert title & subtitle for the Figma Red Card
    String alertTitle = "This item didn't pass authentication";
    String alertSubtitle = isSeller
        ? "Your item is being sent back Estimated delivery: 2–3 days"
        : "Full refund will be credited to your payment method.";

    if (failedStepIndex == 1) {
      alertTitle = "Seller was unavailable for pickup";
      alertSubtitle = isSeller
          ? "The collection attempt failed. Sale was cancelled."
          : "Seller could not complete pickup. Full refund has been issued.";
    } else if (failedStepIndex == 4) {
      alertTitle = "Item was rejected at delivery";
      alertSubtitle = isSeller
          ? "Buyer rejected the item. It is being returned to hub."
          : "Delivery was rejected. Full refund has been issued.";
    } else if (cancellationReason?.isNotEmpty == true) {
      alertSubtitle = cancellationReason!;
    }

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader && headerTitle != null && headerTitle!.isNotEmpty) ...[
            Text(
              headerTitle!,
              style: headerStyle ??
                  GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1.0,
                  ),
            ),
            SizedBox(height: 12.h),
          ],

          // Stepper Box
          Container(
            padding: padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFF161719),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: VerticalStepper(
              steps: steps,
              nodeSize: 26.r,
              activeDashedSize: 26.r,
              lineWidth: 2.w,
              stepHeight: 52.h,
              titleStyle: GoogleFonts.dmSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
              subtitleStyle: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: Colors.white54,
                height: 1.1,
              ),
            ),
          ),

          // ── RED ALERT CARD MATCHING FIGMA DESIGN ───────────────────
          if (isCancelled) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF130E0F),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.65),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alertTitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF453A),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          alertSubtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
