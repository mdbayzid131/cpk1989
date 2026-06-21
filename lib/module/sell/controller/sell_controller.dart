import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

class SellController extends GetxController {
  // Predefined luxury products for high-fidelity mock experience
  final List<Map<String, dynamic>> galleryProducts = [
    {
      "id": "lv_capucines",
      "itemName": "Louis Vuitton Capucines",
      "brand": "Louis Vuitton",
      "imageUrl":
          "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=600&auto=format&fit=crop",
      "price": 18200.0,
      "condition": "Pristine",
      "whySelling": "Upgrading collection",
      "serialNumber": "TR0221",
      "authScore": "99.1%",
    },
    {
      "id": "chanel_flap",
      "itemName": "Chanel Classic Flap Bag",
      "brand": "Chanel",
      "imageUrl":
          "https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=600&auto=format&fit=crop",
      "price": 28500.0,
      "condition": "Excellent",
      "whySelling": "Not in use",
      "serialNumber": "31xxxxxx",
      "authScore": "98.6%",
    },
    {
      "id": "dior_saddle",
      "itemName": "Dior Saddle Bag",
      "brand": "Dior",
      "imageUrl":
          "https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?q=80&w=600&auto=format&fit=crop",
      "price": 12400.0,
      "condition": "Very Good",
      "whySelling": "Closet clearance",
      "serialNumber": "12-MA-0198",
      "authScore": "97.4%",
    },
    {
      "id": "rolex_submariner",
      "itemName": "Rolex Submariner Date",
      "brand": "Rolex",
      "imageUrl":
          "https://images.unsplash.com/photo-1547996160-81dfa63595aa?q=80&w=600&auto=format&fit=crop",
      "price": 52000.0,
      "condition": "Pristine",
      "whySelling": "Investment flip",
      "serialNumber": "V839201",
      "authScore": "99.8%",
    },
  ];

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
    resetToProduct(1);
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

  void resetToProduct(int index) {
    if (index < 0 || index >= galleryProducts.length) return;
    selectedItemIndex.value = index;
    rxCapturedPath.value = "";
    isPreviewMode.value = false;

    final product = galleryProducts[index];
    itemNameInput.value = product["itemName"];
    conditionInput.value = product["condition"];
    whySellingInput.value = product["whySelling"];
    customBrand.value = product["brand"];
    customPrice.value = product["price"];
    customSerial.value = product["serialNumber"];
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

  // Take photo from real camera
  Future<void> capturePhoto(void Function() onFinish) async {
    if (cameraController != null && isCameraInitialized.value) {
      try {
        final XFile file = await cameraController!.takePicture();
        rxCapturedPath.value = file.path;
        confirmCapture();
        onFinish();
      } catch (e) {
        Get.snackbar(
          "Capture Error",
          "Failed to take picture: ${e.toString()}",
        );
      }
    } else {
      // Fallback if camera is unavailable (simulator mode)
      rxCapturedPath.value = ""; // blank means fallback to mockup network image
      confirmCapture();
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
        rxCapturedPath.value = file.path;
        confirmCapture();
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

  // Confirm and proceed from camera to AI Analysis
  void confirmCapture() {
    if (rxCapturedPath.value.isNotEmpty) {
      // User captured/selected a custom file
      itemNameInput.value = "Gallery Selected Item";
      customBrand.value = "Authentic Product";
      customPrice.value = 15000.0;
      customSerial.value =
          "CAPTURED-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    } else {
      // Simulator template fallback
      final product = galleryProducts[selectedItemIndex.value];
      itemNameInput.value = product["itemName"];
      customBrand.value = product["brand"];
      customPrice.value = product["price"];
      customSerial.value = product["serialNumber"];
    }

    Get.toNamed(AppRoutes.aiAnalysis);
  }

  // Trigger AI analysis flow
  void startAIAnalysis(void Function() onFinish) {
    isScanning.value = true;
    scanProgress.value = 0.0;
    currentScanStepIndex.value = 0;

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (scanProgress.value < 1.0) {
        scanProgress.value += 0.03;
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
      final selectedProduct = galleryProducts[selectedItemIndex.value];

      // If user captured/picked local path, use it; otherwise fallback to selected preset's network url
      final finalImagePath = rxCapturedPath.value.isNotEmpty
          ? rxCapturedPath.value
          : selectedProduct["imageUrl"];

      final newItem = ProfileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: finalImagePath,
        price: customPrice.value > 0
            ? customPrice.value
            : selectedProduct["price"],
        likes: 0,
        isSold: false,
        brand: customBrand.value.isNotEmpty
            ? customBrand.value
            : selectedProduct["brand"],
        itemName: itemNameInput.value.isNotEmpty
            ? itemNameInput.value
            : selectedProduct["itemName"],
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
        "Item has been simulated to be listed in your Wardrobe.",
      );
    }
  }

  // Add scanned item to wardrobe silently and return the profile item (for automatic details route)
  ProfileItem addScannedItemToWardrobeSilently() {
    final profileController = Get.put(ProfileController());
    final selectedProduct = galleryProducts[selectedItemIndex.value];

    // If user captured/picked local path, use it; otherwise fallback to selected preset's network url
    final finalImagePath = rxCapturedPath.value.isNotEmpty
        ? rxCapturedPath.value
        : selectedProduct["imageUrl"];

    final newItem = ProfileItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: finalImagePath,
      price: customPrice.value > 0
          ? customPrice.value
          : selectedProduct["price"],
      likes: 0,
      isSold: false,
      brand: customBrand.value.isNotEmpty
          ? customBrand.value
          : selectedProduct["brand"],
      itemName: itemNameInput.value.isNotEmpty
          ? itemNameInput.value
          : selectedProduct["itemName"],
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
