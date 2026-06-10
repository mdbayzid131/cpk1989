import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerificationBottomSheetContent extends StatefulWidget {
  final String email;
  final VoidCallback onVerifySuccess;

  const EmailVerificationBottomSheetContent({
    super.key,
    required this.email,
    required this.onVerifySuccess,
  });

  @override
  State<EmailVerificationBottomSheetContent> createState() =>
      _EmailVerificationBottomSheetContentState();
}

class _EmailVerificationBottomSheetContentState
    extends State<EmailVerificationBottomSheetContent> {
  int _secondsRemaining = 45;
  late final Timer _timer;
  String _otpCode = "";
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTimer() {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading
        Center(
          child: Text(
            "Verify your email",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
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
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white38,
              ),
              children: [
                const TextSpan(text: "We've sent a verification code to\n"),
                TextSpan(
                  text: widget.email,
                  style: GoogleFonts.manrope(
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
        OtpInputWidget(
          onChanged: (code) {
            _otpCode = code;
          },
        ),
        SizedBox(height: 24.h),

        // Timer or Resend Button
        Center(
          child: _secondsRemaining > 0
              ? Text(
                  "Resend code in ${_formatTimer()}",
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : TextButton(
                  onPressed: () {
                    setState(() {
                      _secondsRemaining = 45;
                    });
                    _startTimer();
                  },
                  child: Text(
                    "Resend Code",
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      color: const Color(0xFFE2B744),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        SizedBox(height: 24.h),

        // Gold Gradient Verify Button
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.r),
            gradient: _isButtonLoading
                ? null
                : const LinearGradient(
                    colors: [
                      Color(0xFFAF7413),
                      Color(0xFFC98C28),
                      Color(0xFFE2B744),
                      Color(0xFFFFED81),
                      Color(0xFFE1C24E),
                      Color(0xFFA06008),
                    ],
                    stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: _isButtonLoading ? const Color(0xFF1E2022) : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isButtonLoading ? null : _verifyOtp,
              borderRadius: BorderRadius.circular(26.r),
              child: Center(
                child: _isButtonLoading
                    ? SizedBox(
                        height: 20.w,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE2B744),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Verify Email",
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 18.sp,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _verifyOtp() async {
    setState(() {
      _isButtonLoading = true;
    });

    // Simulate OTP verification delay for premium feel
    await Future.delayed(const Duration(milliseconds: 1000));
    debugPrint("Verifying OTP code: $_otpCode");

    setState(() {
      _isButtonLoading = false;
    });

    widget.onVerifySuccess();
  }
}

class OtpInputWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const OtpInputWidget({super.key, required this.onChanged});

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 48.w,
          height: 54.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C1E),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? const Color(0xFFE2B744)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: GoogleFonts.manrope(
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
                widget.onChanged(_getOtp());
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
                if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
