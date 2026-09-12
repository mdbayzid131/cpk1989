import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class MyItemDetailController extends GetxController {
  late final ProfileItem item;
  final rxOriginalPackaging = false.obs;

  final rxBillPath = "".obs;
  final rxBillName = "".obs;

  late final PageController pageController;
  final rxCurrentPage = 0.obs;
  final rxIsEditing = false.obs;
  final rxIsSaving = false.obs;

  // Text Controllers for Editing
  late final TextEditingController titleController;
  late final TextEditingController brandController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  final rxSelectedCondition = "Excellent".obs;
  final List<String> conditionOptions = [
    'New with Tags',
    'Like New',
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
  ];

  ProductRepository get _productRepo => Get.find<ProductRepository>();

  bool get isReserved {
    final st = (item.status ?? '').toLowerCase();
    return item.isSold || st == 'reserved' || st == 'secured' || st == 'sold' || st == 'in_transit';
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.88);

    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      item = ProfileItem(
        id: 'fallback',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: false,
        brand: "",
        itemName: "",
        status: null,
      );
    }

    if (item.proofOfPurchase != null && item.proofOfPurchase!.isNotEmpty) {
      rxBillName.value = item.proofOfPurchase!.split('/').last.split('\\').last;
      rxBillPath.value = item.proofOfPurchase!;
    }
    if (item.originalPackagingAvailable != null) {
      rxOriginalPackaging.value = item.originalPackagingAvailable!;
    }

    titleController = TextEditingController(text: item.itemName);
    brandController = TextEditingController(text: item.brand);
    descriptionController = TextEditingController(
      text: "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
    );
    priceController = TextEditingController(
      text: item.price > 0 ? item.price.toInt().toString() : "3200",
    );
  }

  /// Pick Bill File (Image or PDF) matching sell flow
  void pickBillFile() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title: Cormorant Garamond matching other modals
                  Center(
                    child: Text(
                      "Upload Proof of Purchase",
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // 1. Pick Image from Gallery
                  _buildUploadOptionTile(
                    icon: Icons.photo_library_outlined,
                    iconColor: const Color(0xFFFFAF2C),
                    title: "Pick Image from Gallery",
                    subtitle: "Select an image from your photo library",
                    onTap: () async {
                      Get.back();
                      try {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          rxBillPath.value = picked.path;
                          rxBillName.value = picked.name;
                        }
                      } catch (e) {
                        Helpers.showError("Failed to pick image: $e");
                      }
                    },
                  ),
                  SizedBox(height: 12.h),

                  // 2. Pick Document (PDF)
                  _buildUploadOptionTile(
                    icon: Icons.picture_as_pdf_outlined,
                    iconColor: const Color(0xFFFFAF2C),
                    title: "Pick Document (PDF)",
                    subtitle: "Select a PDF document from your files",
                    onTap: () async {
                      Get.back();
                      try {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );
                        if (result != null && result.files.single.path != null) {
                          rxBillPath.value = result.files.single.path!;
                          rxBillName.value = result.files.single.name;
                        }
                      } catch (e) {
                        Helpers.showError("Failed to pick document: $e");
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Cancel text button
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 24.w,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildUploadOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF181A1E),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20.r),
                ),
              ),
              SizedBox(width: 14.w),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeBillFile() {
    rxBillPath.value = "";
    rxBillName.value = "";
  }

  void toggleEdit() {
    if (isReserved) return;
    rxIsEditing.value = !rxIsEditing.value;
  }

  Future<void> saveChanges() async {
    if (item.id == 'fallback' || item.id.isEmpty) {
      rxIsEditing.value = false;
      return;
    }

    rxIsSaving.value = true;
    try {
      Helpers.showLoadingDialog(message: "Updating product...");

      final priceVal = double.tryParse(priceController.text) ?? item.price;

      // Determine proofOfPurchase URL string value (Backend Zod schema enforces z.string().url())
      String? proofUrl;
      if (rxBillPath.value.startsWith('http://') ||
          rxBillPath.value.startsWith('https://')) {
        proofUrl = rxBillPath.value;
      } else if (item.proofOfPurchase != null &&
          (item.proofOfPurchase!.startsWith('http://') ||
              item.proofOfPurchase!.startsWith('https://'))) {
        proofUrl = item.proofOfPurchase;
      }

      final updateData = <String, dynamic>{
        "name": titleController.text.trim(),
        "brand": brandController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": priceVal,
        "condition": rxSelectedCondition.value,
        "originalPackagingAvailable": rxOriginalPackaging.value,
      };

      if (proofUrl != null && proofUrl.isNotEmpty) {
        updateData["proofOfPurchase"] = proofUrl;
      }

      final response = await _productRepo.updateProduct(item.id, updateData);
      Get.back(); // dismiss loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        rxIsEditing.value = false;
        Get.snackbar(
          'Success',
          'Product updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: Colors.white,
        );

        // Refresh profile wardrobe if available
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchMyWardrobe();
        }
      } else {
        final msg = response.data?['message'] ?? 'Failed to update product.';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: const Color(0xFFFF453A),
        );
      }
    } catch (e) {
      Get.back(); // dismiss loading
      debugPrint('⚠️ Error saving product changes: $e');
      Get.snackbar(
        'Error',
        'Unable to update product. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: const Color(0xFFFF453A),
      );
    } finally {
      rxIsSaving.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    titleController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
