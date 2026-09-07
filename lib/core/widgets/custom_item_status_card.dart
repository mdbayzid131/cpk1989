import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/vertical_stepper.dart';

/// A reusable custom card for displaying item/order delivery status stepper.
class CustomItemStatusCard extends StatelessWidget {
  final String? status;
  final String? headerTitle;
  final TextStyle? headerStyle;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool showHeader;

  const CustomItemStatusCard({
    super.key,
    required this.status,
    this.headerTitle = "Delivery Status",
    this.headerStyle,
    this.margin,
    this.padding,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final rawSt = (status ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    // Determine current completed step index (0-4)
    int currentStepIndex = 0;
    if (rawSt == 'pending_payment' ||
        rawSt == 'secured' ||
        rawSt == 'reserved' ||
        rawSt == 'pending' ||
        rawSt.isEmpty) {
      currentStepIndex = 0;
    } else if (rawSt == 'collection_pending' ||
        rawSt == 'awaiting_collection' ||
        rawSt == 'collected' ||
        rawSt == 'in_transit') {
      currentStepIndex = 1;
    } else if (rawSt == 'verification' ||
        rawSt == 'authenticating' ||
        rawSt == 'authenticated' ||
        rawSt == 'payout_processing') {
      currentStepIndex = 2;
    } else if (rawSt == 'ready_for_delivery' ||
        rawSt == 'dispatched' ||
        rawSt == 'dispatch' ||
        rawSt == 'out_for_delivery') {
      currentStepIndex = 3;
    } else if (rawSt == 'delivered' || rawSt == 'completed') {
      currentStepIndex = 4;
    }

    final titles = const [
      "Reserved",
      "Collected",
      "Authenticating",
      "Dispatched",
      "Delivered",
    ];

    final subtitles = const [
      "Item reserved for you",
      "Picked up from seller",
      "Being verified by experts",
      "Out for delivery",
      "Successfully delivered to you",
    ];

    final List<StepperStep> steps = List.generate(5, (index) {
      StepperStepState state;
      if (index <= currentStepIndex) {
        state = StepperStepState.completed;
      } else {
        state = StepperStepState.inactive;
      }

      return StepperStep(
        title: titles[index],
        subtitle: subtitles[index],
        state: state,
      );
    });

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader && headerTitle != null && headerTitle!.isNotEmpty) ...[
            Text(
              headerTitle!,
              style:
                  headerStyle ??
                  GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA2A2A2),
                  ),
            ),
            SizedBox(height: 16.h),
          ],
          Container(
            padding:
                padding ??
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
        ],
      ),
    );
  }
}
