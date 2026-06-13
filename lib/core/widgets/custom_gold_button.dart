import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===================== CUSTOM GOLD BUTTON =====================
/// Reusable premium gold button with:
/// - CSS-matching background linear gradient
/// - CSS-matching 1px border gradient (top-to-bottom white/grey opacity)
/// - Custom text, onTap action, and optional suffix widget (e.g. arrow icon)
class CustomGoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Widget? suffix;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomGoldButton({
    super.key,
    required this.text,
    this.onTap,
    this.suffix,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 46.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x66FFFFFF), // rgba(255, 255, 255, 0.4) at 0%
            Color(0x66E8E8E8), // rgba(232, 232, 232, 0.4) at 100%
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.0), // 1px border width
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: const LinearGradient(
            begin: Alignment(
              -1.0,
              -0.165,
            ), // 99.37deg angle: horizontal with slight vertical tilt
            end: Alignment(1.0, 0.165),
            colors: [
              Color(0xFFAF7413), // #AF7413 at 4.77%
              Color(0xFFC98C28), // #C98C28 at 19.33%
              Color(0xFFE2B744), // #E2B744 at 38.93%
              Color(0xFFFFED81), // #FFED81 at 50.54%
              Color(0xFFE1C24E), // #E1C24E at 62.1%
              Color(0xFFA06008), // #A06008 at 90.74%
            ],
            stops: [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100.r),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20.w,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          style: GoogleFonts.dmSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color:
                                Colors.black, // Dark text color matching design
                          ),
                        ),
                        if (suffix != null) ...[SizedBox(width: 8.w), suffix!],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
