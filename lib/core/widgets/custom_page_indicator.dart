import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ===================== CUSTOM PAGE INDICATOR =====================
/// Reusable pill-shaped indicator dots for sliders matching CSS specifications.
class CustomPageIndicator extends StatelessWidget {
  final int count;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;
  final Color? backgroundColor;
  final bool isSmall;
  final bool showBorder;

  const CustomPageIndicator({
    super.key,
    required this.count,
    required this.currentPage,
    this.activeColor = const Color(0xFFFFAF2C),
    this.inactiveColor = const Color(0xFF7E7E7E), // Solid grey matching figma screenshot
    this.backgroundColor,
    this.isSmall = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = isSmall ? 38.w : 53.w;
    final height = isSmall ? 14.h : 18.h;
    final dotSize = isSmall ? 4.w : 6.w;
    final gap = isSmall ? 2.w : 3.w;
    final bgColor = backgroundColor ?? const Color(0xFF0F1012);

    final container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(40),
        border: showBorder
            ? Border.all(color: const Color(0x330F1012), width: 1)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == currentPage;
          return Container(
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : gap),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : inactiveColor,
            ),
          );
        }),
      ),
    );

    // Only apply ClipRRect and BackdropFilter when using the default translucent glass variant.
    // When a solid custom background color is provided, we skip the blur filter to prevent anti-aliasing artifacts.
    if (backgroundColor != null) {
      return container;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: container,
      ),
    );
  }
}
