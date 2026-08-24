import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';

/// A reusable custom empty state widget for screens such as Wishlist, Wardrobe, Cart, Search, etc.
///
/// Configurable with custom image/SVG/icon, title, subtitle, and action button.
class CustomEmptyState extends StatelessWidget {
  /// Path to SVG or PNG asset (e.g. 'assets/images/wishlist_new.svg')
  final String? imagePath;

  /// Custom Widget to display as illustration instead of [imagePath]
  final Widget? imageWidget;

  /// Fallback icon if [imagePath] and [imageWidget] are null or fail to load
  final IconData fallbackIcon;

  /// Size (width/height) of the illustration image or icon
  final double? imageSize;

  /// Color for fallback icon
  final Color? iconColor;

  /// Main title text (e.g. "Nothing Saved Yet")
  final String title;

  /// Subtitle / description text (e.g. "Start exploring luxury pieces\nyou love")
  final String? subtitle;

  /// Button label (e.g. "Explore Items"). If null or empty, button is hidden.
  final String? buttonText;

  /// Callback when the action button is tapped
  final VoidCallback? onButtonTap;

  /// Custom suffix widget for action button (defaults to right arrow)
  final Widget? buttonSuffix;

  /// Custom width for action button
  final double? buttonWidth;

  /// Custom height for action button
  final double? buttonHeight;

  /// Height constraint for the container
  final double? height;

  /// Outer padding
  final EdgeInsetsGeometry? padding;

  const CustomEmptyState({
    super.key,
    this.imagePath,
    this.imageWidget,
    this.fallbackIcon = Icons.favorite_rounded,
    this.imageSize,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
    this.buttonSuffix,
    this.buttonWidth,
    this.buttonHeight,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final double defaultIconSize = imageSize ?? 140.r;

    return Container(
      height: height,
      constraints: height == null
          ? BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5)
          : null,
      alignment: Alignment.center,
      padding: padding ??
          (height != null
              ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h)
              : EdgeInsets.fromLTRB(24.w, 0, 24.w, 90.h)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Image / Illustration / Icon
          _buildIllustration(defaultIconSize),
          SizedBox(height: 24.h),

          // 2. Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // 3. Subtitle (if provided)
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9E9E9E),
                height: 1.4,
              ),
            ),
          ],

          // 4. Action Button (if provided)
          if (buttonText != null && buttonText!.isNotEmpty) ...[
            SizedBox(height: 32.h),
            CustomGoldButton(
              text: buttonText!,
              width: buttonWidth ?? double.infinity,
              height: buttonHeight ?? 46.h,
              suffix: buttonSuffix ??
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 18.r,
                  ),
              onTap: onButtonTap,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration(double defaultIconSize) {
    if (imageWidget != null) {
      return imageWidget!;
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      final isSvg = imagePath!.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.asset(
          imagePath!,
          width: imageSize,
          height: imageSize,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(defaultIconSize),
        );
      } else {
        return Image.asset(
          imagePath!,
          width: imageSize,
          height: imageSize,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(defaultIconSize),
        );
      }
    }

    return _buildFallbackIcon(defaultIconSize);
  }

  Widget _buildFallbackIcon(double size) {
    return Icon(
      fallbackIcon,
      size: size,
      color: iconColor ?? const Color(0xFFFF453A),
    );
  }
}
