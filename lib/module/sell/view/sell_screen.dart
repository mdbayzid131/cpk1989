import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:cpk1989/core/widgets/custom_glass_button.dart';
import 'package:cpk1989/core/widgets/video_preview_widget.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';

class SellScreen extends GetView<SellController> {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Preview Simulation
          Obx(() {
            if (controller.isPreviewMode.value) {
              final path = controller.rxCapturedPath.value;
              final isVideo =
                  path.endsWith('.mp4') ||
                  path.endsWith('.mov') ||
                  path.endsWith('.3gp');
              if (path.isNotEmpty) {
                if (isVideo) {
                  return Positioned.fill(
                    child: VideoPreviewWidget(videoPath: path, muted: true),
                  );
                } else {
                  return Positioned.fill(
                    child: Image.file(File(path), fit: BoxFit.cover),
                  );
                }
              } else {
                return Positioned.fill(
                  child: Image.network(
                    controller.galleryProducts[controller
                        .selectedItemIndex
                        .value]["imageUrl"],
                    fit: BoxFit.cover,
                  ),
                );
              }
            } else if (controller.isCameraInitialized.value &&
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
                      height:
                          controller.cameraController!.value.previewSize!.width,
                      child: CameraPreview(controller.cameraController!),
                    ),
                  ),
                ),
              );
            } else if (controller.isCameraError.value) {
              final activeIndex = controller.selectedItemIndex.value;
              final item = controller.galleryProducts[activeIndex];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Image.network(
                  item["imageUrl"],
                  key: ValueKey<int>(activeIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE2B744),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE2B744),
                    ),
                  ),
                ),
              );
            }
          }),

          // Vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Viewfinder Bracket Corners
          _buildViewfinderBrackets(),

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
                  style: GoogleFonts.manrope(
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
                    iconColor = const Color(0xFFFFAF2C);
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

          // 4. Viewfinder bottom details cards row
          Positioned(
            bottom: 210.h,
            left: 20.w,
            right: 20.w,
            child: Obx(() {
              return Row(
                children: [
                  _buildGlassInfoCard(
                    "What is it?",
                    controller.itemNameInput.value,
                    () => _showEditDialog(
                      "What is it?",
                      controller.itemNameInput,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildGlassInfoCard(
                    "Condition?",
                    controller.conditionInput.value,
                    () => _showSelectorDialog(
                      "Condition?",
                      controller.conditionInput,
                      ["Pristine", "Excellent", "Very Good", "Good", "Fair"],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildGlassInfoCard(
                    "Why selling?",
                    controller.whySellingInput.value,
                    () => _showEditDialog(
                      "Why selling?",
                      controller.whySellingInput,
                    ),
                  ),
                ],
              );
            }),
          ),

          // 5. Mode Selector: PHOTO | VIDEO
          Positioned(
            bottom: 146.h,
            left: 0,
            right: 0,
            child: Obx(() {
              final isPhoto = controller.isPhotoMode.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeTab(
                    "PHOTO",
                    isPhoto,
                    () => controller.toggleCameraMode(true),
                  ),
                  SizedBox(width: 8.w),
                  _buildModeTab(
                    "VIDEO",
                    !isPhoto,
                    () => controller.toggleCameraMode(false),
                  ),
                ],
              );
            }),
          ),

          // 6. Camera / Preview controls
          Obx(() {
            if (controller.isPreviewMode.value) {
              return Positioned(
                bottom: 40.h,
                left: 48.w,
                right: 48.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Retake (Cross) Button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomGlassButton(
                          size: 64.r,
                          onTap: () => controller.retakeCapture(),
                          child: Icon(
                            Icons.close_rounded,
                            color: const Color(0xFFFF453A),
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Retake",
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    // Confirm (Tick) Button with Gold Gradient
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => controller.confirmCapture(),
                          child: Container(
                            width: 76.r,
                            height: 76.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFAF7413),
                                  Color(0xFFC98C28),
                                  Color(0xFFE2B744),
                                  Color(0xFFFFED81),
                                  Color(0xFFE1C24E),
                                  Color(0xFFA06008),
                                ],
                                stops: [
                                  0.0477,
                                  0.1933,
                                  0.3893,
                                  0.5054,
                                  0.6210,
                                  0.9074,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFC98C28,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 16.r,
                                  spreadRadius: 2.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.black,
                                size: 36.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Confirm",
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE2B744),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              // Live camera controls
              return Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: 250.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Gallery Picker (Squircle outline)
                            GestureDetector(
                              onTap: () => controller.pickFromGallery(() {}),
                              child: Container(
                                width: 32.r,
                                height: 32.r,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),

                            // Capture Shutter Button + RECORD label
                            Obx(() {
                              final isPhoto = controller.isPhotoMode.value;
                              final isRec = controller.isRecording.value;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (isPhoto) {
                                        controller.capturePhoto(() {});
                                      } else {
                                        if (isRec) {
                                          controller.stopVideoRecording(() {});
                                        } else {
                                          controller.startVideoRecording();
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 48.r,
                                      height: 48.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.2.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(3.r),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isPhoto
                                              ? Colors.white
                                              : (isRec
                                                    ? const Color(0xFFFF3B30)
                                                    : Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    isPhoto
                                        ? "CAPTURE"
                                        : (isRec ? "STOP" : "RECORD"),
                                    style: GoogleFonts.manrope(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // Flip Camera (Switches front/back lenses)
                            GestureDetector(
                              onTap: () => controller.flipCameraHardware(),
                              child: Container(
                                width: 32.r,
                                height: 32.r,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.sync_rounded,
                                  color: Colors.white,
                                  size: 26.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // Bracket overlay rendering corners
  Widget _buildViewfinderBrackets() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(
          left: 36.w,
          right: 36.w,
          top: 140.h,
          bottom: 310.h,
        ),
        child: Stack(
          children: [
            // Top Left Corner
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 3.5.w),
                    top: BorderSide(color: Colors.white, width: 3.5.w),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            // Top Right Corner
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white, width: 3.5.w),
                    top: BorderSide(color: Colors.white, width: 3.5.w),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            // Bottom Left Corner
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 3.5.w),
                    bottom: BorderSide(color: Colors.white, width: 3.5.w),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            // Bottom Right Corner
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white, width: 3.5.w),
                    bottom: BorderSide(color: Colors.white, width: 3.5.w),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info display overlay capsule
  Widget _buildGlassInfoCard(String label, String value, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    value.isEmpty ? "Tap to add" : value,
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty ? Colors.white30 : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mode Selection Tab Option
  Widget _buildModeTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // Modal edit dialog for card titles/reasons
  void _showEditDialog(String title, RxString textRx) {
    final textController = TextEditingController(text: textRx.value);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161719),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Edit $title",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter value...",
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24, width: 1.w),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2B744), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCEL",
              style: GoogleFonts.manrope(
                color: Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              textRx.value = textController.text.trim();
              Get.back();
            },
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Color(0xFFE2B744),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Option dropdown sheets for conditions
  void _showSelectorDialog(
    String title,
    RxString selectedRx,
    List<String> options,
  ) {
    Get.dialog(
      SimpleDialog(
        backgroundColor: const Color(0xFF161719),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Select $title",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        children: options.map((opt) {
          final isSelected = selectedRx.value == opt;
          return SimpleDialogOption(
            onPressed: () {
              selectedRx.value = opt;
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    opt,
                    style: GoogleFonts.manrope(
                      color: isSelected
                          ? const Color(0xFFE2B744)
                          : Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: Color(0xFFE2B744), size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //   // Simulated Gallery Picker modal bottom sheet
  //   void _showGallerySheet(BuildContext context) {
  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: const Color(0xFF121315),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
  //       ),
  //       builder: (context) {
  //         return SafeArea(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ListTile(
  //                 leading: Icon(
  //                   Icons.photo_library_rounded,
  //                   color: const Color(0xFFE2B744),
  //                   size: 22.sp,
  //                 ),
  //                 title: Text(
  //                   "Choose from Device Gallery",
  //                   style: GoogleFonts.manrope(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   controller.pickFromGallery(() {});
  //                 },
  //               ),
  //               const Divider(color: Colors.white10),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
  //                 child: Text(
  //                   "Or select a test template item:",
  //                   style: GoogleFonts.manrope(
  //                     fontSize: 12.sp,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.white38,
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                 height: 280.h,
  //                 padding: EdgeInsets.symmetric(horizontal: 16.w),
  //                 child: GridView.builder(
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 2,
  //                     crossAxisSpacing: 12.w,
  //                     mainAxisSpacing: 12.h,
  //                     childAspectRatio: 1.1,
  //                   ),
  //                   itemCount: controller.galleryProducts.length,
  //                   itemBuilder: (context, index) {
  //                     final product = controller.galleryProducts[index];
  //                     return GestureDetector(
  //                       onTap: () {
  //                         controller.resetToProduct(index);
  //                         Navigator.pop(context);
  //                       },
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(16.r),
  //                           border: Border.all(
  //                             color: controller.selectedItemIndex.value == index
  //                                 ? const Color(0xFFE2B744)
  //                                 : Colors.white10,
  //                             width: 2.w,
  //                           ),
  //                         ),
  //                         child: Stack(
  //                           fit: StackFit.expand,
  //                           children: [
  //                             ClipRRect(
  //                               borderRadius: BorderRadius.circular(14.r),
  //                               child: Image.network(
  //                                 product["imageUrl"],
  //                                 fit: BoxFit.cover,
  //                               ),
  //                             ),
  //                             Positioned(
  //                               bottom: 0,
  //                               left: 0,
  //                               right: 0,
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   gradient: LinearGradient(
  //                                     colors: [
  //                                       Colors.transparent,
  //                                       Colors.black.withValues(alpha: 0.8),
  //                                     ],
  //                                     begin: Alignment.topCenter,
  //                                     end: Alignment.bottomCenter,
  //                                   ),
  //                                   borderRadius: BorderRadius.vertical(
  //                                     bottom: Radius.circular(14.r),
  //                                   ),
  //                                 ),
  //                                 padding: EdgeInsets.all(8.w),
  //                                 child: Text(
  //                                   product["itemName"],
  //                                   style: GoogleFonts.manrope(
  //                                     fontSize: 11.sp,
  //                                     fontWeight: FontWeight.w600,
  //                                     color: Colors.white,
  //                                   ),
  //                                   maxLines: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                               ),
  //                             ),
  //                             if (controller.selectedItemIndex.value == index)
  //                               Positioned(
  //                                 top: 8.h,
  //                                 right: 8.w,
  //                                 child: Container(
  //                                   padding: EdgeInsets.all(4.r),
  //                                   decoration: const BoxDecoration(
  //                                     color: Color(0xFFE2B744),
  //                                     shape: BoxShape.circle,
  //                                   ),
  //                                   child: const Icon(
  //                                     Icons.check,
  //                                     color: Colors.black,
  //                                     size: 12,
  //                                   ),
  //                                 ),
  //                               ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               SizedBox(height: 12.h),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
}
