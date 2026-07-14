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

  const CustomPageIndicator({
    super.key,
    required this.count,
    required this.currentPage,
    this.activeColor = const Color(0xFFFFAF2C),
    this.inactiveColor = const Color(
      0xFF7E7E7E,
    ), // Solid grey matching figma screenshot
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: 53.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: const Color(
              0xFF0F1012,
            ), // semi-transparent to show backdrop blur
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0x330F1012), // #0F101233 border
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(count, (index) {
              final isActive = index == currentPage;
              return Container(
                margin: EdgeInsets.only(right: index == count - 1 ? 0 : 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : inactiveColor,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
