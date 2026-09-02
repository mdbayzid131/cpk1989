import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/module/auth/controller/auth_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';

class EmailVerificationBottomSheetContent extends GetView<AuthController> {
  const EmailVerificationBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final email = controller.emailController.text.trim().isNotEmpty
        ? controller.emailController.text.trim()
        : "gretchen.bothman@gmail.com";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading
        Center(
          child: Text(
            "Verify your email",
            style: TextStyle(
              fontFamily: 'Schnyder L',
              fontSize: 30.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Subheading
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white38,
              ),
              children: [
                const TextSpan(text: "We've sent a verification code to\n"),
                TextSpan(
                  text: email,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 28.h),

        // OTP inputs
        OtpInputWidget(controller: controller),
        SizedBox(height: 24.h),

        // Timer or Resend Button
        Obx(() {
          final secondsRemaining = controller.rxOtpSecondsRemaining.value;
          return Center(
            child: secondsRemaining > 0
                ? Text(
                    "Resend code in ${controller.formattedOtpTimer}",
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      final success = await controller.resendOtp();
                      if (success) {
                        controller.startOtpTimer();
                      }
                    },
                    child: Text(
                      "Resend Code",
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        color: const Color(0xFFE2B744),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          );
        }),
        SizedBox(height: 24.h),

        // Gold Gradient Verify Button
        Obx(() {
          return CustomGoldButton(
            text: "Verify Email",
            isLoading: controller.rxIsOtpLoading.value,
            suffix: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 18.sp,
            ),
            onTap: () async {
              final success = await controller.verifyOtp();
              if (success && context.mounted) {
                Navigator.pop(context); // Close bottom sheet
                await controller.handleVerificationSuccess();
              }
            },
          );
        }),
      ],
    );
  }
}

class OtpInputWidget extends StatelessWidget {
  final AuthController controller;

  const OtpInputWidget({super.key, required this.controller});

  void _handleOtpInput(String value, int index, AuthController controller) {
    final cleanDigits = value.replaceAll(RegExp(r'\D'), '');

    if (cleanDigits.length > 1) {
      final startIdx = cleanDigits.length >= 6 ? 0 : index;
      for (int i = 0; i < 6; i++) {
        final digitIdx = i - startIdx;
        if (digitIdx >= 0 && digitIdx < cleanDigits.length) {
          controller.otpControllers[i].text = cleanDigits[digitIdx];
        }
      }
      final nextFocus = (startIdx + cleanDigits.length).clamp(0, 5);
      final targetIdx = startIdx + cleanDigits.length >= 6 ? 5 : nextFocus;
      controller.otpFocusNodes[targetIdx].requestFocus();
      return;
    }

    if (cleanDigits.length == 1) {
      controller.otpControllers[index].text = cleanDigits;
      if (index < 5) {
        controller.otpFocusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty) {
      if (index > 0) {
        controller.otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return Focus(
            onFocusChange: (_) {
              // Trigger rebuild of individual container on focus change
            },
            child: Builder(
              builder: (context) {
                final hasFocus = Focus.of(context).hasFocus;
                return Container(
                  width: 48.w,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C1E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: hasFocus
                          ? const Color(0xFFE2B744)
                          : Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: controller.otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _handleOtpInput(value, index, controller);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
