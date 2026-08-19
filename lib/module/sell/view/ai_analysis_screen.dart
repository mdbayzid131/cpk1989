import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final SellController controller = Get.find<SellController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start AI analysis logic
      controller.startAIAnalysis(() {
        if (mounted) {
          final newItem = controller.addScannedItemToWardrobeSilently();
          Get.offAndToNamed(AppRoutes.sellItemDetail, arguments: newItem);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background image
            _buildBackgroundPreview(),

            // 2. Dark Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.black.withValues(alpha: 0.55)),
              ),
            ),

            // 3. Centered Custom Gold Loader & Processing text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomGoldLoader(size: 52.r, strokeWidth: 3.5.r),
                  SizedBox(height: 16.h),
                  Text(
                    "Processing..",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackgroundPreview() {
    final path = controller.rxCapturedPath.value;
    if (path.isNotEmpty && File(path).existsSync()) {
      return Positioned.fill(child: Image.file(File(path), fit: BoxFit.cover));
    }
    return const SizedBox.shrink();
  }
}
