# Flutter Camera Integration Guide

This guide details the complete process of integrating and managing a hardware camera in Flutter, including lens switching, photo/video capture, flash synchronization (torch fallback), preview/retake flows, and resource disposal.

---

## 1. Project Configuration & Permissions

To access physical camera hardware and the gallery, add the required dependencies and platform configurations.

### Dependencies (`pubspec.yaml`)
Add these dependencies to your `pubspec.yaml` file:
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+9      # Natively communicates with iOS/Android camera APIs
  image_picker: ^1.1.2   # Handles gallery photo/video selection
  get: ^4.6.6            # State management (optional, can use vanilla/Provider/Bloc)
```

### iOS Configuration (`ios/Runner/Info.plist`)
Add key-value strings detailing why your app requests these inputs:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture items you want to list for sale.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record sound for your item listing videos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need gallery access to let you choose item photos from your library.</string>
```

### Android Configuration (`android/app/build.gradle`)
Ensure your `minSdkVersion` is at least **21** (required by the `camera` plugin).

---

## 2. Camera Controller Initialization

Initialize the camera controller by retrieving available device sensors and instantiating a `CameraController` targeting the back camera.

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraService {
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isFrontCamera = false.obs;

  Future<void> initializeCamera() async {
    try {
      // 1. Fetch available physical cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // 2. Select target lens (Front vs Back)
      final lensDir = isFrontCamera.value 
          ? CameraLensDirection.front 
          : CameraLensDirection.back;
          
      CameraDescription targetCam = cameras.firstWhere(
        (cam) => cam.lensDirection == lensDir, 
        orElse: () => cameras.first
      );

      // 3. Instantiate controller
      cameraController = CameraController(
        targetCam,
        ResolutionPreset.medium, // Options: low, medium, high, veryHigh, ultraHigh, max
        enableAudio: true,       // Enable microphone for video recording
      );

      // 4. Initialize and set initialized flag
      await cameraController!.initialize();
      isCameraInitialized.value = true;
      
      // 5. Initial flash synchronization
      await syncFlashMode();
    } catch (e) {
      debugPrint("Camera Initialization Error: $e");
    }
  }
}
```

---

## 3. Flash Mode Management & Synchronization

Flash synchronization requires specific mappings for photo and video modes:
- **Photo Mode**: Uses `FlashMode.always` or `FlashMode.auto`.
- **Video Mode**: `FlashMode.always` throws errors during active recording. You must use `FlashMode.torch` to keep the LED bulb continuously lit.

```dart
final flashState = "off".obs; // States: "off", "on", "auto"
final isPhotoMode = true.obs;

Future<void> syncFlashMode() async {
  if (cameraController == null || !isCameraInitialized.value) return;

  try {
    FlashMode mode;
    if (flashState.value == "on") {
      // Photo mode uses standard flash; Video mode requires continuous Torch
      mode = isPhotoMode.value ? FlashMode.always : FlashMode.torch;
    } else if (flashState.value == "auto") {
      mode = FlashMode.auto;
    } else {
      mode = FlashMode.off;
    }
    
    await cameraController!.setFlashMode(mode);
  } catch (e) {
    // Fallback: If FlashMode.always is unsupported on target camera (e.g., front camera), try Torch
    if (flashState.value == "on" && isPhotoMode.value) {
      try {
        await cameraController!.setFlashMode(FlashMode.torch);
      } catch (_) {}
    }
    debugPrint("Flash Synchronization Error: $e");
  }
}

// Flash Toggle Trigger
void toggleFlash() {
  if (flashState.value == "off") {
    flashState.value = "on";
  } else if (flashState.value == "on") {
    flashState.value = "auto";
  } else {
    flashState.value = "off";
  }
  syncFlashMode();
}
```

---

## 4. Capturing Photos & Video Recording

### Photo Capture
To capture a static photo, invoke `takePicture()` and retain the path:
```dart
final rxCapturedPath = "".obs;
final isPreviewMode = false.obs;

Future<void> capturePhoto() async {
  if (cameraController != null && isCameraInitialized.value) {
    try {
      final XFile file = await cameraController!.takePicture();
      rxCapturedPath.value = file.path;
      isPreviewMode.value = true; // Switch view to review state
    } catch (e) {
      debugPrint("Photo Capture Error: $e");
    }
  }
}
```

### Video Capture & Duration Tracking
Use `startVideoRecording()` and `stopVideoRecording()`. Use a periodic timer to track recording elapsed time:
```dart
final isRecording = false.obs;
final recordingSeconds = 0.obs;
Timer? recordingTimer;

Future<void> startVideoRecording() async {
  if (cameraController != null && isCameraInitialized.value) {
    try {
      await cameraController!.startVideoRecording();
      isRecording.value = true;
      recordingSeconds.value = 0;
      
      // Start timer tracking duration
      recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingSeconds.value++;
      });
    } catch (e) {
      debugPrint("Start Video Recording Error: $e");
    }
  }
}

Future<void> stopVideoRecording() async {
  isRecording.value = false;
  recordingTimer?.cancel();
  recordingTimer = null;

  if (cameraController != null && isCameraInitialized.value) {
    try {
      final XFile file = await cameraController!.stopVideoRecording();
      rxCapturedPath.value = file.path;
      isPreviewMode.value = true; // Show preview player
    } catch (e) {
      debugPrint("Stop Video Recording Error: $e");
    }
  }
}
```

---

## 5. Camera Flipping (Front <-> Back Lens)

To switch camera lenses, dispose of the current controller stream, toggle the lens direction state, and call the initialization routine.

```dart
Future<void> flipCamera() async {
  final cameras = await availableCameras();
  if (cameras.length < 2) return; // Requires at least front and back lenses

  // 1. Toggle state
  isFrontCamera.value = !isFrontCamera.value;

  // 2. Tear down existing controller resources
  isCameraInitialized.value = false;
  await cameraController?.dispose();
  cameraController = null;

  // 3. Re-initialize hardware with new lens target
  await initializeCamera();
}
```

---

## 6. Preview State: Retake & Confirm

Provide a review loop for users to review their media before uploading.

```dart
// Retake Callback: Deletes local reference and returns to live feed
void retakeCapture() {
  rxCapturedPath.value = "";
  isPreviewMode.value = false;
}

// Confirm Callback: Proceeds to server-side uploads or AI processing
void confirmCapture() {
  final finalPath = rxCapturedPath.value;
  // Route to analysis/upload screen using finalPath
}
```

---

## 7. Memory Leak Prevention & Disposal

Ensure the camera hardware resources are released when the user leaves the screen:

```dart
@override
void onClose() {
  recordingTimer?.cancel();
  cameraController?.dispose(); // Releases camera lock
  super.onClose();
}
```

---

## 8. Frontend UI View Preview

### Camera Preview Screen Layout Structure
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // 1. Camera Live View or Preview Media
        Obx(() {
          if (isPreviewMode.value) {
            // Render captured photo image or video loop preview player
            return Image.file(File(rxCapturedPath.value));
          } else if (isCameraInitialized.value && cameraController != null) {
            // Live Stream
            return CameraPreview(cameraController!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
        
        // 2. Control Overlays
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => toggleFlash(),
          ),
        ),
      ],
    ),
  );
}
```
