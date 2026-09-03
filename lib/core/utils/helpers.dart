import 'dart:io';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

enum SnackBarType { success, error, info, warning, secondary }

/// ===================== HELPERS =====================
/// Common utility functions used across the app.
class Helpers {
  Helpers._();

  /// Open default email client with support@closete.app
  static Future<void> openSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@closete.app',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      showError("Could not launch email app for support@closete.app");
    }
  }

  /// Open Proof of Bill / PDF / Image in an in-app modal pop-up
  static Future<void> openUrl(String url, {String title = "Proof of Bill"}) async {
    if (url.trim().isEmpty) return;

    try {
      String fullUrl = url.trim();
      final bool isHttp =
          fullUrl.startsWith('http://') || fullUrl.startsWith('https://');
      final bool isLocalFile =
          !isHttp && (fullUrl.startsWith('/') || fullUrl.contains('/'));

      if (!isHttp && !isLocalFile && !fullUrl.startsWith('assets/')) {
        fullUrl = fullUrl.startsWith('/')
            ? 'https://champagne-plates-sunday-lion.trycloudflare.com$fullUrl'
            : 'https://champagne-plates-sunday-lion.trycloudflare.com/$fullUrl';
      }

      final BuildContext? context = Get.context;
      if (context == null) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.88,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1C1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                // Top drag indicator handle
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 12.h),

                // Modal Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Download button
                      _DocumentDownloadButton(fileUrl: fullUrl),
                      SizedBox(width: 8.w),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 24.h,
                ),

                // Document Content Area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF121315),
                        child: _buildDocumentContent(fullUrl),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      showError("Could not open document");
    }
  }

  static Widget _buildDocumentContent(String fullUrl) {
    final lower = fullUrl.toLowerCase();
    final bool isPdf = lower.contains('.pdf');
    final bool isImage = lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp');

    if (isPdf) {
      return InAppPdfViewerWidget(pdfUrl: fullUrl);
    }

    if (fullUrl.startsWith('/') && File(fullUrl).existsSync()) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            File(fullUrl),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => InAppPdfViewerWidget(pdfUrl: fullUrl),
          ),
        ),
      );
    }

    if (isImage ||
        (!isPdf &&
            (fullUrl.startsWith('http') || fullUrl.startsWith('assets/')))) {
      return InteractiveViewer(
        child: Center(
          child: fullUrl.startsWith('assets/')
              ? Image.asset(fullUrl, fit: BoxFit.contain)
              : Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CustomGoldLoader(size: 40));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return InAppPdfViewerWidget(pdfUrl: fullUrl);
                  },
                ),
        ),
      );
    }

    return InAppPdfViewerWidget(pdfUrl: fullUrl);
  }

  // ──────────────────── TIME FORMATTING ────────────────────

  /// Format seconds to "mm:ss" (e.g., 125 → "02:05")
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  /// Format DateTime to "time ago" string (e.g., "5m ago")
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  /// Format seconds to "HH:mm:ss" (e.g., 3661 → "01:01:01")
  static String formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$mins:$secs';
  }

  // ──────────────────── LOGGING ────────────────────

  /// General debug log (only in debug mode)
  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('🔍🔍🔍 DEBUG: $message');
    debugPrint('');
  }

  /// Info-level log
  static void info(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('ℹ️ℹ️ℹ️ℹ INFO: $message');
    debugPrint('');
  }

  /// Warning-level log
  static void warning(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('⚠️⚠️⚠️ WARNING: $message');
    debugPrint('');
  }

  /// Error-level log
  static void error(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('❌❌❌❌ ERROR: $message');
    debugPrint('');
  }

  // ──────────────────── LOADING DIALOG ────────────────────

  /// Show a centered loading spinner dialog
  static void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomGoldLoader(size: 52.r, strokeWidth: 3.5.r),
              SizedBox(height: 16.h),
              Material(
                color: Colors.transparent,
                child: Text(
                  message ?? "Processing..",
                  style: GoogleFonts.dmSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
    );
  }

  /// Dismiss loading dialog if open
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // ──────────────────── SNACKBAR (DUAL MODE) ────────────────────

  /// Show a snackbar.
  /// [useGetxSnackbar] = true (default) → uses Get.snackbar with type-specific colors.
  /// [useGetxSnackbar] = false → uses the premium blurred iPhone-style snackbar.
  static void showCustomSnackBar(
    String message, {
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    bool useGetxSnackbar = true,
  }) {
    final Map<String, dynamic> config = _getSnackBarConfig(type);

    if (useGetxSnackbar) {
      // ── GetX Snackbar (default) ──────────────────────────────
      Get.snackbar(
        "",
        "",
        titleText: const SizedBox.shrink(),
        messageText: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title ?? config['defaultTitle'] as String,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.25,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.25,
              ),
            ),
          ],
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: (config['bg'] as Color).withValues(alpha: 0.92),
        colorText: Colors.white,
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        animationDuration: const Duration(milliseconds: 450),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      );
    } else {
      // ── Custom Blur / Glassmorphism Snackbar ─────────────────
      Get.rawSnackbar(
        messageText: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: (config['bg'] as Color).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  // Text Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? config['defaultTitle'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        duration: duration,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 500),
        snackStyle: SnackStyle.FLOATING,
      );
    }
  }

  static Map<String, dynamic> _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return {
          'bg': const Color(0xFF161719),
          'iconBg': const Color(0xFF161719),
          'icon': Icons.check_rounded,
          'defaultTitle': 'Success',
        };
      case SnackBarType.error:
        return {
          'bg': const Color(0xFFEF4444),
          'iconBg': const Color(0xFFDC2626),
          'icon': Icons.block_rounded,
          'defaultTitle': 'Error',
        };
      case SnackBarType.warning:
        return {
          'bg': const Color(0xFFF59E0B),
          'iconBg': const Color(0xFFD97706),
          'icon': Icons.warning_rounded,
          'defaultTitle': 'Warning',
        };
      case SnackBarType.secondary:
        return {
          'bg': const Color(0xFF3B82F6),
          'iconBg': const Color(0xFF2563EB),
          'icon': Icons.notifications_none_rounded,
          'defaultTitle': 'Secondary',
        };
      case SnackBarType.info:
        return {
          'bg': const Color(0xFF9CA3AF),
          'iconBg': const Color(0xFF6B7280),
          'icon': Icons.info_outline_rounded,
          'defaultTitle': 'Info',
        };
    }
  }

  /// Shortcut for Success
  static void showSuccess(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.success);
  }

  /// Shortcut for Error
  static void showError(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.error);
  }

  /// Shortcut for Warning
  static void showWarning(String message, {String? title}) {
    showCustomSnackBar(message, title: title, type: SnackBarType.warning);
  }

  // ──────────────────── KEYBOARD ────────────────────

  /// Dismiss keyboard
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ──────────────────── DEBOUNCE ────────────────────

  static final Map<String, bool> _debounceTimers = {};

  /// Debounce a function call (useful for search inputs)
  static void debounce(
    String tag,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    if (GetUtils.isNull(tag)) return;

    // If already waiting, skip
    if (_debounceTimers[tag] == true) return;

    _debounceTimers[tag] = true;
    Future.delayed(duration, () {
      _debounceTimers.remove(tag);
      callback();
    });
  }
}

class InAppPdfViewerWidget extends StatefulWidget {
  final String pdfUrl;
  const InAppPdfViewerWidget({super.key, required this.pdfUrl});

  @override
  State<InAppPdfViewerWidget> createState() => _InAppPdfViewerWidgetState();
}

class _InAppPdfViewerWidgetState extends State<InAppPdfViewerWidget> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.pdfUrl.startsWith('/') && File(widget.pdfUrl).existsSync()) {
        if (mounted) {
          setState(() {
            _localPath = widget.pdfUrl;
            _isLoading = false;
          });
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final filename = "proof_${widget.pdfUrl.hashCode.abs()}.pdf";
      final file = File("${dir.path}/$filename");

      if (await file.exists() && (await file.length()) > 0) {
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
        return;
      }

      final dio = Dio();
      await dio.download(widget.pdfUrl, file.path);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Could not load PDF document";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomGoldLoader(size: 44),
          SizedBox(height: 16.h),
          Text(
            "Loading PDF Document...",
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
        ],
      );
    }

    if (_error != null || _localPath == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 56.sp,
                color: const Color(0xFFE2B744),
              ),
              SizedBox(height: 16.h),
              Text(
                "Proof of Bill Document",
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Tap below to view full document preview inside app",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2B744),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () async {
                  final uri = Uri.parse(widget.pdfUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.inAppBrowserView,
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  "Open Document View",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          backgroundColor: const Color(0xFF121315),
          onRender: (pages) {
            if (mounted) {
              setState(() {
                _totalPages = pages ?? 0;
              });
            }
          },
          onPageChanged: (page, total) {
            if (mounted) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _error = error.toString();
              });
            }
          },
        ),
        if (_totalPages > 0)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                "${_currentPage + 1} / $_totalPages",
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A dedicated download button for the in-app document viewer
class _DocumentDownloadButton extends StatefulWidget {
  final String fileUrl;

  const _DocumentDownloadButton({required this.fileUrl});

  @override
  State<_DocumentDownloadButton> createState() =>
      _DocumentDownloadButtonState();
}

class _DocumentDownloadButtonState extends State<_DocumentDownloadButton> {
  bool _isDownloading = false;

  Future<void> _download() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final String url = widget.fileUrl.trim();
      final bool isHttp =
          url.startsWith('http://') || url.startsWith('https://');

      String ext = ".pdf";
      final lower = url.toLowerCase();
      if (lower.contains('.png')) {
        ext = '.png';
      } else if (lower.contains('.jpg') || lower.contains('.jpeg')) {
        ext = '.jpg';
      } else if (lower.contains('.webp')) {
        ext = '.webp';
      }

      // Check if already cached in temporary directory
      final tempDir = await getTemporaryDirectory();
      final cacheFilename = "proof_${url.hashCode.abs()}.pdf";
      final cachedFile = File("${tempDir.path}/$cacheFilename");
      final bool isCached =
          await cachedFile.exists() && (await cachedFile.length()) > 0;

      // Determine destination directory
      Directory? targetDir;
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          try {
            final testFile = File(
                '${downloadDir.path}/.test_${DateTime.now().millisecondsSinceEpoch}');
            await testFile.writeAsString('test');
            await testFile.delete();
            targetDir = downloadDir;
          } catch (_) {
            targetDir = null;
          }
        }
        targetDir ??= await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }

      final fileName = "CPK_${DateTime.now().millisecondsSinceEpoch}$ext";
      final savePath = "${targetDir.path}/$fileName";

      if (isCached) {
        await cachedFile.copy(savePath);
      } else if (isHttp) {
        final dio = Dio();
        await dio.download(url, savePath);
      } else if (File(url).existsSync()) {
        await File(url).copy(savePath);
      } else {
        throw "Invalid file source";
      }

      debugPrint("📁 [Download] File saved successfully at: $savePath");

      Helpers.showCustomSnackBar(
        Platform.isAndroid
            ? "File saved to Downloads: $fileName"
            : "File saved to device memory: $fileName",
        title: "Download Complete",
        type: SnackBarType.success,
      );
    } catch (e) {
      Helpers.showError("Could not save file: $e");
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isDownloading ? null : _download,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: "Download Document",
      icon: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: _isDownloading
            ? SizedBox(
                width: 18.sp,
                height: 18.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2.r,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.file_download_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
      ),
    );
  }
}

