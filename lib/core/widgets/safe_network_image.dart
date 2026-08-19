import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cpk1989/core/controllers/internet_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

/// ===================== SAFE NETWORK IMAGE =====================
/// Network image widget with graceful error/offline fallback.
/// Uses CachedNetworkImage-like behavior with built-in loading/error states.
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final internet = Get.find<InternetController>();

    // Show fallback if no internet or empty URL
    if (!internet.hasInternet.value || imageUrl.isEmpty) {
      return _buildFallback();
    }

    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildFallback(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: const Color(0xff8E8E93),
        size: 24.sp,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: CustomGoldLoader(size: 20.r, strokeWidth: 2.r),
    );
  }
}
