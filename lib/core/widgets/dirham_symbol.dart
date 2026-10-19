import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable UAE Dirham Currency Symbol Widget
class DirhamSymbol extends StatelessWidget {
  final double? size;
  final Color color;

  const DirhamSymbol({
    super.key,
    this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 12.sp;
    return SvgPicture.asset(
      'assets/icons/dirham_symbol.svg',
      width: s,
      height: s,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Inline span for Text.rich / RichText
  static InlineSpan span({
    double? size,
    Color color = Colors.white,
    EdgeInsetsGeometry? padding,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: padding ?? EdgeInsets.only(right: 3.w),
        child: SvgPicture.asset(
          'assets/icons/dirham_symbol.svg',
          width: size ?? 12.sp,
          height: size ?? 12.sp,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// Reusable Widget that formats any price with the official UAE Dirham Symbol
class DirhamPrice extends StatelessWidget {
  final String price; // e.g. "2,500" or "AED 2,500" or raw number
  final TextStyle? style;
  final double? symbolSize;
  final Color? color;
  final double spacing;
  final MainAxisSize mainAxisSize;
  final bool fitScaleDown;

  const DirhamPrice({
    super.key,
    required this.price,
    this.style,
    this.symbolSize,
    this.color,
    this.spacing = 3.0,
    this.mainAxisSize = MainAxisSize.min,
    this.fitScaleDown = false,
  });

  String _cleanPrice(String raw) {
    return raw.replaceAll('AED', '').replaceAll('aed', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? style?.color ?? Colors.white;
    final fontSize = style?.fontSize ?? 14.sp;
    final sSize = symbolSize ?? (fontSize * 0.82);

    Widget content = Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/dirham_symbol.svg',
          width: sSize,
          height: sSize,
          colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
        ),
        SizedBox(width: spacing.w),
        Text(
          _cleanPrice(price),
          style: style ??
              GoogleFonts.dmSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
        ),
      ],
    );

    if (fitScaleDown) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: content,
      );
    }

    return content;
  }
}
