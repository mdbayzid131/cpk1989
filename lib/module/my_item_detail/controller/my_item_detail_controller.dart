import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/models/order_model.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/data/repositories/payment_repository.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/utils/status_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class MyItemDetailController extends GetxController {
  late final ProfileItem item;
  final rxOriginalPackaging = false.obs;

  final rxBillPath = "".obs;
  final rxBillName = "".obs;

  late final PageController pageController;
  final rxCurrentPage = 0.obs;
  final rxIsEditing = false.obs;
  final rxIsSaving = false.obs;

  // Dynamic Full Details
  final rxOrderModel = Rxn<OrderModel>();
  final rxBuyerModel = Rxn<OrderBuyerModel>();
  final rxProductModel = Rxn<ProductModel>();
  final rxCancellationReason = "".obs;
  final rxIsLoadingDetails = false.obs;

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

  final rxIsCheckingConnectStatus = false.obs;
  final rxIsStripeOnboarded = false.obs;

  bool get isReserved {
    final liveOrderSt = rxOrderModel.value?.status;
    final st = liveOrderSt ?? item.status;
    return StatusHelper.isOrderReservedOrSold(
          st,
          isSold: item.isSold,
        ) ||
        StatusHelper.isCancelledOrRefunded(st) ||
        rxOrderModel.value != null;
  }

  /// Active orders in progress (reserved, collected, authenticating, dispatched) cannot be deleted.
  /// Items with pending_review, rejected, delivered/completed, or unsold items can be deleted.
  bool get canDelete {
    final orderStatus = (rxOrderModel.value?.status ?? '').toLowerCase();
    if (orderStatus == 'reserved' ||
        orderStatus == 'collected' ||
        orderStatus == 'authenticating' ||
        orderStatus == 'dispatched') {
      return false;
    }
    if (isReserved) {
      final prodStatus = (rxProductModel.value?.status ?? item.status ?? '').toLowerCase();
      if (prodStatus != 'delivered' &&
          prodStatus != 'completed' &&
          prodStatus != 'refunded' &&
          prodStatus != 'cancelled' &&
          prodStatus != 'rejected' &&
          prodStatus != 'pending_review' &&
          prodStatus != 'pending' &&
          orderStatus != 'refunded' &&
          orderStatus != 'cancelled') {
        return false;
      }
    }
    return true;
  }

  /// Only items that are in review (`pending_review` / `pending`) or `rejected` can be edited.
  bool get canEdit {
    final orderStatus = (rxOrderModel.value?.status ?? '').toLowerCase();
    if (orderStatus.isNotEmpty) return false;
    if (isReserved) return false;

    final prodStatus = (rxProductModel.value?.status ?? item.status ?? '').toLowerCase();
    return prodStatus == 'pending_review' ||
        prodStatus == 'pending' ||
        prodStatus == 'rejected';
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.88);
    // checkStripeConnectStatus(); // Payout account status check disabled for Item Detail screen

    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else if (Get.arguments is String) {
      item = ProfileItem(
        id: Get.arguments as String,
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: false,
        brand: "",
        itemName: "",
        status: null,
      );
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      item = ProfileItem(
        id: map['productId']?.toString() ?? map['id']?.toString() ?? 'fallback',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: false,
        brand: "",
        itemName: "",
        status: map['status']?.toString(),
      );
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

    if (item.orderModel != null) {
      rxOrderModel.value = item.orderModel;
    }
    if (item.productModel?.buyer != null) {
      rxBuyerModel.value = item.productModel!.buyer;
    }
    if (item.productModel != null) {
      rxProductModel.value = item.productModel;
    }

    if (item.proofOfPurchase != null && item.proofOfPurchase!.isNotEmpty) {
      rxBillName.value = item.proofOfPurchase!.split('/').last.split('\\').last;
      rxBillPath.value = item.proofOfPurchase!;
    }
    if (item.originalPackagingAvailable != null) {
      rxOriginalPackaging.value = item.originalPackagingAvailable!;
    }
    if (item.condition != null && item.condition!.isNotEmpty) {
      rxSelectedCondition.value = item.condition!;
    }

    titleController = TextEditingController(text: item.itemName);
    brandController = TextEditingController(text: item.brand);
    descriptionController = TextEditingController(
      text: (item.description != null && item.description!.isNotEmpty)
          ? item.description!
          : "",
    );
    priceController = TextEditingController(
      text: item.price > 0
          ? (item.price == item.price.roundToDouble()
              ? item.price.toInt().toString()
              : item.price.toStringAsFixed(2))
          : "0",
    );

    // Fetch full order and buyer details asynchronously
    fetchFullDetails();
  }

  Future<void> fetchFullDetails() async {
    final targetId = item.id;
    if (targetId.isEmpty || targetId == 'fallback') return;

    rxIsLoadingDetails.value = true;
    try {
      final res = await _productRepo.getProductById(targetId);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          final prod = ProductModel.fromJson(data);
          rxProductModel.value = prod;
          if (prod.order != null) {
            rxOrderModel.value = prod.order;
            if (prod.order!.cancellationReason != null &&
                prod.order!.cancellationReason!.isNotEmpty) {
              rxCancellationReason.value = prod.order!.cancellationReason!;
            }
          }
          if (data['order'] is Map) {
            final oMap = data['order'];
            if (oMap['cancellationReason'] != null &&
                oMap['cancellationReason'].toString().isNotEmpty) {
              rxCancellationReason.value = oMap['cancellationReason'].toString();
            } else if (oMap['note'] != null &&
                oMap['note'].toString().isNotEmpty) {
              rxCancellationReason.value = oMap['note'].toString();
            }
          }
          if (prod.buyer != null) {
            rxBuyerModel.value = prod.buyer;
          }
          if (prod.name != null && prod.name!.isNotEmpty) {
            titleController.text = prod.name!;
          }
          if (prod.brand != null && prod.brand!.isNotEmpty) {
            brandController.text = prod.brand!;
          }
          if (prod.description != null && prod.description!.isNotEmpty) {
            descriptionController.text = prod.description!;
          }
          if (prod.price != null && prod.price! > 0) {
            priceController.text = (prod.price == prod.price!.roundToDouble())
                ? prod.price!.toInt().toString()
                : prod.price!.toStringAsFixed(2);
          }
          if (prod.condition != null && prod.condition!.isNotEmpty) {
            rxSelectedCondition.value = prod.condition!;
          }
          if (prod.originalPackagingAvailable != null) {
            rxOriginalPackaging.value = prod.originalPackagingAvailable!;
          }
          if (prod.proofOfPurchase != null && prod.proofOfPurchase!.isNotEmpty) {
            rxBillPath.value = prod.proofOfPurchase!;
            rxBillName.value =
                prod.proofOfPurchase!.split('/').last.split('\\').last;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetch full item details error: $e');
    } finally {
      rxIsLoadingDetails.value = false;
    }
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
      final currentProdStatus = (rxProductModel.value?.status ?? item.status ?? '').toLowerCase();
      final bool wasRejected = currentProdStatus == 'rejected';

      final updateData = <String, dynamic>{
        "name": titleController.text.trim(),
        "brand": brandController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": priceVal,
        "condition": rxSelectedCondition.value,
        "originalPackagingAvailable": rxOriginalPackaging.value,
      };

      if (wasRejected) {
        updateData["status"] = "pending_review";
        updateData["rejectionReason"] = "";
      }

      String? localProofPath;
      if (rxBillPath.value.isNotEmpty) {
        if (rxBillPath.value.startsWith('http://') ||
            rxBillPath.value.startsWith('https://')) {
          updateData["proofOfPurchase"] = rxBillPath.value;
        } else {
          localProofPath = rxBillPath.value;
        }
      } else {
        updateData["proofOfPurchase"] = null;
      }

      final response = await _productRepo.updateProduct(
        item.id,
        updateData,
        proofOfPurchasePath: localProofPath,
      );
      Get.back(); // dismiss loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        rxIsEditing.value = false;
        await fetchFullDetails();

        Get.snackbar(
          'Success',
          wasRejected
              ? 'Product updated and submitted for review!'
              : 'Product updated successfully!',
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

  Future<void> checkStripeConnectStatus({bool showLoading = false}) async {
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.put(PaymentRepository());
    }
    final paymentRepo = Get.find<PaymentRepository>();

    rxIsCheckingConnectStatus.value = true;
    if (showLoading) {
      Helpers.showLoadingDialog(message: "Checking payout status...");
    }

    try {
      final statusData = await paymentRepo.getConnectStatus();
      final bool isReady =
          statusData['connected'] == true &&
          statusData['detailsSubmitted'] == true &&
          statusData['payoutsEnabled'] == true;

      rxIsStripeOnboarded.value = isReady;
    } catch (_) {
      rxIsStripeOnboarded.value = false;
    } finally {
      rxIsCheckingConnectStatus.value = false;
      if (showLoading) {
        Helpers.hideLoadingDialog();
      }
    }
  }

  Future<void> startStripeOnboarding() async {
    try {
      Helpers.showLoadingDialog(message: "Generating setup link...");
      if (!Get.isRegistered<PaymentRepository>()) {
        Get.put(PaymentRepository());
      }
      final paymentRepo = Get.find<PaymentRepository>();
      final onboardingUrl = await paymentRepo.createConnectOnboardingUrl();
      Helpers.hideLoadingDialog();

      if (onboardingUrl != null && onboardingUrl.isNotEmpty) {
        final uri = Uri.parse(onboardingUrl);
        // Open Stripe Connect inside In-App Browser/WebView without leaving the app
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        // When returning to app, re-check Stripe Connect status
        await checkStripeConnectStatus(showLoading: false);
      } else {
        Helpers.showError(
          "Unable to generate payout setup link. Please try again.",
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showError("Error starting onboarding: $e");
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
