import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class SellController extends GetxController {
  // Real Camera Hardware Controller state
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isCameraError = false.obs;
  final cameraErrorMessage = "".obs;
  final isFrontCamera = false.obs;
  final imagePicker = ImagePicker();

  // Preview Mode State (shows captured photo/video for review before going to AI Analysis)
  final isPreviewMode = false.obs;

  // Saved media target path (points to local file if captured/picked, or empty to fallback)
  final rxCapturedPath = "".obs;

  // Multi-image capture state: exactly 3 photo slots
  final rxCapturedPaths = <String?>[null, null, null].obs;
  final activeSlotIndex = 0.obs;

  // Flag to check if live camera feed is active/turned on
  final isCameraActive = true.obs;

  // Camera settings state
  final isPhotoMode = true.obs;
  final flashState = "off".obs; // off, on, auto

  // Selected item information state
  final selectedItemIndex = 1.obs; // Defaults to Chanel Classic Flap Bag
  final itemNameInput = "".obs;
  final conditionInput = "".obs;
  final whySellingInput = "".obs;

  // Custom manual entries if overwritten
  final customBrand = "".obs;
  final customPrice = 0.0.obs;
  final customSerial = "".obs;

  // Scanning Screen State
  final isScanning = false.obs;
  final scanProgress = 0.0.obs; // 0.0 to 1.0
  final currentScanStepIndex = 0.obs;
  final scanSteps = <String>[
    "Initializing neural networks...",
    "Scanning brand signatures...",
    "Verifying material texture & pattern...",
    "Comparing hardware & logo engravings...",
    "Validating serial database matching...",
    "Finalizing analysis results...",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    resetToProduct();
    initializeCameraHardware();
  }

  // Set up actual hardware camera instance
  Future<void> initializeCameraHardware() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        isCameraError.value = true;
        cameraErrorMessage.value = "No physical camera available";
        return;
      }

      // Select target camera based on active lens direction state
      final lensDir = isFrontCamera.value
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      CameraDescription targetCam = cameras.first;
      for (var cam in cameras) {
        if (cam.lensDirection == lensDir) {
          targetCam = cam;
          break;
        }
      }

      cameraController = CameraController(
        targetCam,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      isCameraError.value = false;

      // Initial flash sync
      await _syncFlashMode();
    } catch (e) {
      isCameraInitialized.value = false;
      isCameraError.value = true;
      cameraErrorMessage.value = "Camera error: ${e.toString()}";
    }
  }

  // Flip Camera Front <-> Back
  Future<void> flipCameraHardware() async {
    final cameras = await availableCameras();
    if (cameras.length < 2) {
      Get.snackbar(
        "Camera",
        "Only one camera is available on this device.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E1F22).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    isFrontCamera.value = !isFrontCamera.value;

    // Dispose previous controller
    isCameraInitialized.value = false;
    await cameraController?.dispose();
    cameraController = null;

    // Reinitialize hardware camera with the new lens setting
    await initializeCameraHardware();
  }

  void resetToProduct([int index = 0]) {
    selectedItemIndex.value = index;
    rxCapturedPath.value = "";
    rxCapturedPaths.value = [null, null, null];
    activeSlotIndex.value = 0;
    isCameraActive.value = true;
    isPreviewMode.value = false;

    itemNameInput.value = "";
    conditionInput.value = "";
    whySellingInput.value = "";
    customBrand.value = "";
    customPrice.value = 0.0;
    customSerial.value = "";
  }

  void toggleFlash() {
    if (flashState.value == "off") {
      flashState.value = "on";
    } else if (flashState.value == "on") {
      flashState.value = "auto";
    } else {
      flashState.value = "off";
    }
    _syncFlashMode();
  }

  Future<void> _syncFlashMode() async {
    if (cameraController == null || !isCameraInitialized.value) return;
    try {
      FlashMode mode;
      if (flashState.value == "on") {
        mode = FlashMode.always;
      } else if (flashState.value == "auto") {
        mode = FlashMode.auto;
      } else {
        mode = FlashMode.off;
      }
      await cameraController!.setFlashMode(mode);
    } catch (e) {
      if (flashState.value == "on") {
        try {
          await cameraController!.setFlashMode(FlashMode.torch);
        } catch (_) {}
      }
      debugPrint("Camera Flash Error: $e");
    }
  }

  // Take photo from real camera or activate camera preview
  Future<void> capturePhoto(void Function() onFinish) async {
    // If camera feed is not yet active, activate it first
    if (!isCameraActive.value) {
      isCameraActive.value = true;
      onFinish();
      return;
    }

    if (cameraController != null && isCameraInitialized.value) {
      try {
        final XFile file = await cameraController!.takePicture();
        rxCapturedPaths[activeSlotIndex.value] = file.path;
        rxCapturedPath.value = file.path; // update preview compatibility

        // Auto-advance to next empty slot
        final nextEmpty = rxCapturedPaths.indexOf(null);
        if (nextEmpty != -1) {
          activeSlotIndex.value = nextEmpty;
          isCameraActive.value = true; // Open camera by default for next slot
        } else {
          isCameraActive.value = false; // Turn off once all filled
        }

        onFinish();
      } catch (e) {
        Get.snackbar(
          "Capture Error",
          "Failed to take picture: ${e.toString()}",
        );
      }
    } else {
      // Fallback if camera is unavailable (simulator mode)
      rxCapturedPaths[activeSlotIndex.value] =
          "MOCK_CAPTURE_${activeSlotIndex.value}";
      rxCapturedPath.value = ""; // fallback

      // Auto-advance
      final nextEmpty = rxCapturedPaths.indexOf(null);
      if (nextEmpty != -1) {
        activeSlotIndex.value = nextEmpty;
        isCameraActive.value = true; // Open camera by default for next slot
      } else {
        isCameraActive.value = false; // Turn off once all filled
      }
      onFinish();
    }
  }

  // Open real gallery picker via image_picker
  Future<void> pickFromGallery(void Function() onPicked) async {
    try {
      final XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file != null) {
        rxCapturedPaths[activeSlotIndex.value] = file.path;
        rxCapturedPath.value = file.path; // update preview compatibility

        // Auto-advance
        final nextEmpty = rxCapturedPaths.indexOf(null);
        if (nextEmpty != -1) {
          activeSlotIndex.value = nextEmpty;
          isCameraActive.value = true; // Open camera by default for next slot
        } else {
          isCameraActive.value = false;
        }
        onPicked();
      }
    } catch (e) {
      Get.snackbar(
        "Gallery Error",
        "Failed to access gallery: ${e.toString()}",
      );
    }
  }

  // Retake or cancel the current previewed item
  void retakeCapture() {
    rxCapturedPath.value = "";
    isPreviewMode.value = false;
  }

  // Confirm and proceed from camera directly to Item Detail via loading dialog
  Future<void> confirmCapture() async {
    if (customSerial.value.isEmpty) {
      customSerial.value =
          "CAPTURED-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    }

    Helpers.showLoadingDialog(message: "Processing..");
    await Future.delayed(const Duration(milliseconds: 1200));
    final newItem = addScannedItemToWardrobeSilently();
    Helpers.hideLoadingDialog();
    Get.toNamed(AppRoutes.sellItemDetail, arguments: newItem);
  }

  // Trigger AI analysis flow
  void startAIAnalysis(void Function() onFinish) {
    isScanning.value = true;
    scanProgress.value = 0.0;
    currentScanStepIndex.value = 0;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (scanProgress.value < 1.0) {
        scanProgress.value += 0.025;
        if (scanProgress.value > 1.0) scanProgress.value = 1.0;

        // Advance status text steps based on progress
        int nextStep = (scanProgress.value * (scanSteps.length - 1)).floor();
        if (nextStep > currentScanStepIndex.value) {
          currentScanStepIndex.value = nextStep;
        }
      } else {
        timer.cancel();
        isScanning.value = false;
        onFinish();
      }
    });
  }

  // Finalize adding item to Wardrobe list in ProfileController
  void addScannedItemToWardrobe() {
    try {
      final profileController = Get.find<ProfileController>();

      final List<String> finalImages = rxCapturedPaths
          .where((path) => path != null && path.isNotEmpty && !path.startsWith("MOCK_CAPTURE_"))
          .cast<String>()
          .toList();

      final String primaryImage = finalImages.isNotEmpty ? finalImages[0] : "";

      final newItem = ProfileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: primaryImage,
        images: finalImages.isNotEmpty ? finalImages : [primaryImage, primaryImage, primaryImage],
        price: customPrice.value,
        likes: 0,
        isSold: false,
        brand: customBrand.value,
        itemName: itemNameInput.value.isNotEmpty
            ? itemNameInput.value
            : "Item Details",
        status: null, // Null status means active wardrobe listing
      );

      // Add to profile wardrobe items list
      profileController.rxWardrobeItems.insert(0, newItem);

      Get.back(); // Go back from AI Analysis
      Get.back(); // Go back from Camera Screen

      // Select the first tab (Wardrobe) in profile
      profileController.rxSelectedIndex.value = 0;

      Get.snackbar(
        "Success",
        "${newItem.itemName} listed successfully!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E1F22),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.back();
      Get.snackbar(
        "Listed",
        "Item has been listed in your Wardrobe.",
      );
    }
  }

  // Add scanned item to wardrobe silently and return the profile item (for automatic details route)
  ProfileItem addScannedItemToWardrobeSilently() {
    final profileController = Get.put(ProfileController());

    final List<String> finalImages = rxCapturedPaths
        .where((path) => path != null && path.isNotEmpty && !path.startsWith("MOCK_CAPTURE_"))
        .cast<String>()
        .toList();

    final String primaryImage = finalImages.isNotEmpty ? finalImages[0] : "";

    final newItem = ProfileItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: primaryImage,
      images: finalImages.isNotEmpty ? finalImages : [primaryImage, primaryImage, primaryImage],
      price: customPrice.value,
      likes: 0,
      isSold: false,
      brand: customBrand.value,
      itemName: itemNameInput.value.isNotEmpty
          ? itemNameInput.value
          : "Item Details",
      status: null, // Null status means active wardrobe listing
    );

    // Add to profile wardrobe items list
    profileController.rxWardrobeItems.insert(0, newItem);

    // Select the first tab (Wardrobe) in profile
    profileController.rxSelectedIndex.value = 0;

    return newItem;
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
