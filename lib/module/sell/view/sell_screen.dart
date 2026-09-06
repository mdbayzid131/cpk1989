import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cpk1989/config/themes/app_theme.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/custom_gold_button.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';
import 'package:cpk1989/core/widgets/custom_gold_loader.dart';

class SellScreen extends GetView<SellController> {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272729),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview or Static Review Image
          Obx(() {
            final activePath =
                controller.rxCapturedPaths[controller.activeSlotIndex.value];

            if (activePath != null && !activePath.startsWith("MOCK_CAPTURE_")) {
              return Positioned.fill(
                child: Image.file(File(activePath), fit: BoxFit.cover),
              );
            } else {
              // Live camera preview (only if active)
              if (controller.isCameraActive.value) {
                if (controller.isCameraInitialized.value &&
                    controller.cameraController != null) {
                  return Positioned.fill(
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller
                              .cameraController!
                              .value
                              .previewSize!
                              .height,
                          height: controller
                              .cameraController!
                              .value
                              .previewSize!
                              .width,
                          child: CameraPreview(controller.cameraController!),
                        ),
                      ),
                    ),
                  );
                } else if (controller.isCameraError.value) {
                  // Camera error or running on simulator without physical camera
                  return Positioned.fill(
                    child: Container(
                      color: const Color(0xFF0F1012),
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off_outlined,
                            color: Colors.white38,
                            size: 56.r,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Camera Unavailable",
                            style: GoogleFonts.dmSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.cameraErrorMessage.value.isNotEmpty
                                ? controller.cameraErrorMessage.value
                                : "Camera hardware not available on emulator. Please pick photos from gallery.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Camera is initializing: show dark background with sleek loading indicator
                  return Positioned.fill(
                    child: Container(
                      color: const Color(0xFF0F1012),
                      child: Center(child: CustomGoldLoader(size: 40.r)),
                    ),
                  );
                }
              } else {
                // Camera is off (show nothing to let scaffold background show through)
                return const SizedBox.shrink();
              }
            }
          }),

          // 1. Top Gradient Overlay with Backdrop Blur
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 151.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x000D0E10),
                    Color(0xC00D0E10),
                    Color(0xFF0D0E10),
                  ],
                  stops: [0.0, 0.4939, 1.0],
                ),
              ),
            ),
          ),

          // 2. Bottom Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 311.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x000D0E10),
                    Color(0xC00D0E10),
                    Color(0xFF0D0E10),
                  ],
                  stops: [0.0652, 0.4004, 0.8894],
                ),
              ),
            ),
          ),

          // 2. Viewfinder container (centered, rounded corners)
          Positioned(
            top: 110.h,
            left: 20.w,
            right: 20.w,
            height: 350.h,
            child: Obx(() {
              final activePath =
                  controller.rxCapturedPaths[controller.activeSlotIndex.value];
              final isSlotEmpty = activePath == null;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  // border: Border.all(
                  //   color: Colors.white.withValues(alpha: 0.12),
                  //   width: 1.0,
                  // ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Stack(
                    children: [
                      // Viewfinder Brackets Overlay
                      _buildBracketsOverlay(),

                      // Central "+" button if active slot is empty and camera is off (Screenshot 2)
                      if (isSlotEmpty && !controller.isCameraActive.value)
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () => controller.capturePhoto(() {}),
                              child: Container(
                                width: 56.r,
                                height: 56.r,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0F1012),
                                    width: 3.r,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // 3. Top Controller Bar (Close, Title, Flash)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomGlassButton(
                  size: 44.r,
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                Text(
                  "Show your item",
                  style: GoogleFonts.dmSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 8,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final flash = controller.flashState.value;
                  IconData flashIcon;
                  Color iconColor;
                  if (flash == "on") {
                    flashIcon = Icons.flash_on_rounded;
                    iconColor = AppTheme.yellow;
                  } else if (flash == "auto") {
                    flashIcon = Icons.flash_auto_rounded;
                    iconColor = Colors.white;
                  } else {
                    flashIcon = Icons.flash_off_rounded;
                    iconColor = Colors.white54;
                  }

                  return CustomGlassButton(
                    size: 44.r,
                    onTap: () => controller.toggleFlash(),
                    child: Icon(flashIcon, color: iconColor, size: 20.sp),
                  );
                }),
              ],
            ),
          ),

          // 4. Bottom Controls panel containing (Pill Indicator, Instruction, 4-Slots, Action Buttons)
          Positioned(
            bottom: 24.h + MediaQuery.of(context).padding.bottom,
            left: 20.w,
            right: 20.w,
            child: Obx(() {
              final capturedPaths = controller.rxCapturedPaths;
              final capturedCount = capturedPaths
                  .where((p) => p != null)
                  .length;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A. Gold or Grey Pill Capsule Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: capturedCount > 0
                          ? const Color(0xFF3F3328)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      capturedCount == 0
                          ? "Add at least 3 photos"
                          : (capturedCount < 3
                                ? "$capturedCount Of 3 Uploaded"
                                : "$capturedCount Of $capturedCount Uploaded"),
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: capturedCount > 0
                            ? const Color(0xFFFFAF2C)
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  if (capturedCount == 0 || capturedCount >= 3) ...[
                    SizedBox(height: 12.h),
                    Text(
                      capturedCount == 0
                          ? "The first photo will appear in your listing."
                          : "Drag to reorder your photos,\nThe first photo will be your cover image.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ] else ...[
                    SizedBox(height: 15.h),
                  ],

                  // C. 3-Slots Container matching Figma CSS
                  Container(
                    width: 218.w,
                    height: 74.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        final path = capturedPaths[index];
                        final isActive =
                            controller.activeSlotIndex.value == index;

                        final slotContent = Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 62.r,
                              height: 62.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFF252628),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFFFFAF2C)
                                      : const Color(0x1FFFFFFF),
                                  width: isActive ? 1.5.w : 1.w,
                                ),
                              ),
                              child: path != null && !path.startsWith("MOCK_CAPTURE_")
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                            ),
                            // Top-Left Slot Index Badge (flush with image borders)
                            if (path != null)
                              Positioned(
                                top: 1.h,
                                left: 1.w,
                                child: Container(
                                  width: 22.r,
                                  height: 22.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFAF2C),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(9.r),
                                      bottomRight: Radius.circular(10.r),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Top-Right Close/Remove Button (white circle with black outline)
                            if (path != null)
                              Positioned(
                                top: -2.h,
                                right: -2.w,
                                child: GestureDetector(
                                  onTap: () {
                                    capturedPaths[index] = null;
                                    controller.activeSlotIndex.value = index;
                                    controller.isCameraActive.value = true;
                                  },
                                  child: Container(
                                    width: 18.r,
                                    height: 18.r,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.5.w,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.black,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );

                        final mainSlotWidget = GestureDetector(
                          onTap: () {
                            controller.activeSlotIndex.value = index;
                            if (capturedPaths[index] == null) {
                              controller.isCameraActive.value = true;
                            }
                          },
                          child: slotContent,
                        );

                        Widget reorderableSlot = DragTarget<int>(
                          onWillAcceptWithDetails: (details) =>
                              details.data != index,
                          onAcceptWithDetails: (details) {
                            final dragIndex = details.data;
                            final temp = capturedPaths[dragIndex];
                            capturedPaths[dragIndex] = capturedPaths[index];
                            capturedPaths[index] = temp;
                            controller.activeSlotIndex.value = index;
                          },
                          builder: (context, candidateData, rejectedData) {
                            return mainSlotWidget;
                          },
                        );

                        if (path != null) {
                          return Draggable<int>(
                            data: index,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.8,
                                child: Container(
                                  width: 62.r,
                                  height: 62.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF252628),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: !path.startsWith("MOCK_CAPTURE_")
                                        ? Image.file(
                                            File(path),
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: mainSlotWidget,
                            ),
                            child: reorderableSlot,
                          );
                        }

                        return reorderableSlot;
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // D. Shutter / Gallery Picker (Camera Controls) OR Continue button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: (capturedCount >= 3)
                        ? CustomGoldButton(
                            key: const ValueKey('continue_btn'),
                            text: "Continue",
                            suffix: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black,
                            ),
                            onTap: () => controller.confirmCapture(),
                          )
                        : Row(
                            key: const ValueKey('camera_controls'),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gallery Picker Button
                              GestureDetector(
                                onTap: () => controller.pickFromGallery(() {}),
                                child: Container(
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/image_file.svg",
                                      width: 22.r,
                                      height: 22.r,
                                    ),
                                  ),
                                ),
                              ),

                              // Shutter Capture Button
                              GestureDetector(
                                onTap: () => controller.capturePhoto(() {}),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64.r,
                                      height: 64.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(4.r),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "PHOTO",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white54,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Empty placeholder to balance the Shutter button in the center
                              SizedBox(width: 44.r),
                            ],
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Bracket overlay rendering corners centered on the viewfinder aspect ratio
  Widget _buildBracketsOverlay() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Stack(
          children: [
            // Top Left Corner
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 3.w),
                    top: BorderSide(color: Colors.white, width: 3.w),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Top Right Corner
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white, width: 3.w),
                    top: BorderSide(color: Colors.white, width: 3.w),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Bottom Left Corner
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 3.w),
                    bottom: BorderSide(color: Colors.white, width: 3.w),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Bottom Right Corner
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white, width: 3.w),
                    bottom: BorderSide(color: Colors.white, width: 3.w),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
