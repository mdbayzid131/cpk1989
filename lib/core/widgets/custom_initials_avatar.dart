import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable circle avatar widget that displays:
/// 1. The user/seller profile photo if uploaded and valid.
/// 2. Gold initials on dark background (matching Client Design) if image is null/empty/placeholder.
class CustomInitialsAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final double? borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final double? fontSize;
  final FontWeight fontWeight;

  const CustomInitialsAvatar({
    super.key,
    this.imageUrl,
    this.name,
    required this.size,
    this.borderWidth,
    this.borderColor = const Color(0xFFFFAF2C),
    this.backgroundColor = const Color(0xFF0F1012),
    this.textColor = const Color(0xFFFFAF2C),
    this.fontSize,
    this.fontWeight = FontWeight.w700,
  });

  /// Compute two-letter initials from name (e.g. "Costas Kazikkis" -> "CK", "Bayzid Hossain" -> "BH")
  static String getInitials(String? name) {
    final clean = (name ?? '').trim();
    if (clean.isEmpty) return 'U';

    final parts = clean
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      final res = '$first$second'.toUpperCase();
      if (res.isNotEmpty) return res;
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      final single = parts[0];
      return (single.length >= 2 ? single.substring(0, 2) : single)
          .toUpperCase();
    }
    return 'U';
  }

  bool get _hasValidImage {
    if (imageUrl == null) return false;
    final url = imageUrl!.trim();
    if (url.isEmpty || url == 'null') return false;
    if (url.contains('profile.png')) return false; // Ignore generic placeholder
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderWidth = borderWidth ?? (size >= 60.r ? 1.5 : 1.0);
    final effectiveFontSize = fontSize ?? (size * 0.38);

    if (_hasValidImage) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: effectiveBorderWidth,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl!.trim(),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitials(effectiveBorderWidth, effectiveFontSize),
          ),
        ),
      );
    }

    return _buildInitials(effectiveBorderWidth, effectiveFontSize);
  }

  Widget _buildInitials(double bWidth, double fSize) {
    final initials = getInitials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: bWidth),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.dmSans(
            fontSize: fSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: size >= 50.r ? 1.2 : 0.5,
          ),
        ),
      ),
    );
  }
}
