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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF161719),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Upload Proof of Purchase",
              style: GoogleFonts.dmSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(
                  Icons.image_outlined,
                  color: const Color(0xFFFFAF2C),
                  size: 22.sp,
                ),
                title: Text(
                  "Pick Image from Gallery",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                    Get.snackbar(
                      "Error",
                      "Failed to pick image: $e",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF161719),
                      colorText: const Color(0xFFFF453A),
                    );
                  }
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: const Color(0xFFFFAF2C),
                  size: 22.sp,
                ),
                title: Text(
                  "Pick Document (PDF)",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                    Get.snackbar(
                      "Error",
                      "Failed to pick document: $e",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF161719),
                      colorText: const Color(0xFFFF453A),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
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
