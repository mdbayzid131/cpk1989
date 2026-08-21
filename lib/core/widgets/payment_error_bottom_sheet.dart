import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_dipped_bottom_sheet.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';

class PaymentErrorBottomSheetContent extends StatelessWidget {
  final String? title;
  final String? errorMessage;
  final VoidCallback onTryAgain;

  const PaymentErrorBottomSheetContent({
    super.key,
    this.title,
    this.errorMessage,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? "Payment not completed";
    final displayMsg = (errorMessage != null && errorMessage!.trim().isNotEmpty)
        ? errorMessage!
        : "Your card was declined.\nPlease check your details or use another method.";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          displayTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Schnyder L',
            fontSize: 26.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          displayMsg,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        SizedBox(height: 28.h),
        CustomGoldButton(
          text: "Try Again",
          width: double.infinity,
          onTap: onTryAgain,
        ),
      ],
    );
  }
}

/// Show Figma-designed payment error dipped bottom sheet with cross icon
Future<T?> showPaymentErrorBottomSheet<T>({
  required BuildContext context,
  String? title,
  String? errorMessage,
  VoidCallback? onTryAgain,
}) {
  return showCustomDippedBottomSheet<T>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    canPop: true,
    showFlashlight: false,
    logo: Image.asset(
      'assets/icons/cross_icon.png',
      width: 80.r,
      height: 80.r,
      fit: BoxFit.contain,
    ),
    content: PaymentErrorBottomSheetContent(
      title: title,
      errorMessage: errorMessage,
      onTryAgain: () {
        if (onTryAgain != null) {
          onTryAgain();
        } else {
          Navigator.of(context).pop();
        }
      },
    ),
  );
}
