import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/payment_service.dart';

class SecureCheckoutController extends GetxController {
  late final FeedItem item;

  // Gesture Recognizers for checkout footer links
  late final TapGestureRecognizer termsRecognizer;
  late final TapGestureRecognizer purchasePolicyRecognizer;

  // Form Field Controllers
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;

  final rxLocation = "UAE".obs;
  final rxPhoneCode = "+971".obs;

  // Selected Payment Method: 'apple_pay', 'google_pay', or 'card'
  final rxPaymentMethod = "card".obs;
  final rxIsCardSheetOpen = false.obs;

  ProfileController get profileController {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    return Get.find<ProfileController>();
  }

  final rxSelectedCardId = "".obs;

  // Processing state
  final rxIsProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<PaymentService>()) {
      Get.put(PaymentService());
    }

    profileController.fetchSavedCards();
    ever(profileController.rxSavedCards, (cards) {
      if (rxSelectedCardId.value.isEmpty && cards.isNotEmpty) {
        rxSelectedCardId.value = cards.first.id;
      }
    });
    if (profileController.rxSavedCards.isNotEmpty) {
      rxSelectedCardId.value = profileController.rxSavedCards.first.id;
    }

    termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed(AppRoutes.termsAndPolicies);
      };
    purchasePolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed(AppRoutes.termsAndConditions, arguments: "Purchase Policy");
      };

    if (Get.arguments is FeedItem) {
      item = Get.arguments as FeedItem;
    } else {
      // Fallback
      item = FeedItem(
        imagePath: '',
        userName: 'Olivia Mendes',
        condition: 'Excellent',
        itemName: 'Classic Flap Bag',
        price: '3,200',
        wornCount: 'N/A',
        size: 'N/A',
        description: 'Black caviar leather with gold hardware.',
      );
    }

    // Try to load default user info from ProfileController if available
    try {
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      final profileController = Get.find<ProfileController>();
      firstNameController = TextEditingController(
        text: profileController.firstNameController.text.isEmpty
            ? "Olivia"
            : profileController.firstNameController.text,
      );
      lastNameController = TextEditingController(
        text: profileController.lastNameController.text.isEmpty
            ? "Mendes"
            : profileController.lastNameController.text,
      );
      addressController = TextEditingController(
        text: profileController.addressController.text.isEmpty
            ? "Palm Jumeirah, Building 5, Apt 1204"
            : profileController.addressController.text,
      );
      phoneController = TextEditingController(
        text: profileController.phoneController.text.isEmpty
            ? "50 123 4567"
            : profileController.phoneController.text,
      );
      rxLocation.value = "UAE";
    } catch (_) {
      firstNameController = TextEditingController(text: "");
      lastNameController = TextEditingController(text: "");
      addressController = TextEditingController(
        text: "Palm Jumeirah, Building 5, Apt 1204",
      );
      phoneController = TextEditingController(text: "50 123 4567");
      rxLocation.value = "UAE";
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    termsRecognizer.dispose();
    purchasePolicyRecognizer.dispose();
    super.onClose();
  }

  void selectPaymentMethod(String method) {
    rxPaymentMethod.value = method;
  }

  bool validateDeliveryDetails() {
    if (addressController.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Address",
        "Please enter your delivery address.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Phone",
        "Please enter your phone number.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  Future<ProfileItem?> processPurchase() async {
    if (!validateDeliveryDetails()) return null;

    if (rxPaymentMethod.value == "card" &&
        profileController.rxSavedCards.isEmpty) {
      return null;
    }

    rxIsProcessing.value = true;

    double finalPrice = 3200.0;
    try {
      finalPrice = double.parse(item.price.replaceAll(',', ''));
    } catch (_) {}

    final selectedCardId = rxSelectedCardId.value.isNotEmpty
        ? rxSelectedCardId.value
        : (profileController.rxSavedCards.isNotEmpty
              ? profileController.rxSavedCards.first.id
              : null);

    final paymentResult = await PaymentService.to.processPayment(
      paymentMethod: rxPaymentMethod.value,
      productId: item.id.isNotEmpty ? item.id : 'unknown',
      address: addressController.text.trim(),
      location: rxLocation.value,
      phone: '${rxPhoneCode.value} ${phoneController.text.trim()}',
      selectedPaymentMethodId: rxPaymentMethod.value == "card"
          ? selectedCardId
          : null,
    );

    rxIsProcessing.value = false;

    if (!paymentResult.success) {
      if (!paymentResult.isCancelled) {
        final errorMsg =
            paymentResult.errorMessage ??
            "Payment could not be completed. Please try again.";
        Get.dialog(
          Dialog(
            backgroundColor: const Color(0xFF1C1D20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Colors.redAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C1C1D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Payment Error",
                    style: GoogleFonts.dmSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    errorMsg,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2B744),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Okay",
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return null;
    }

    // Create purchased item using real order data from backend API
    final realOrder = paymentResult.orderData;
    final realOrderNumber = realOrder?.orderNumber ?? '';
    final realPrice = realOrder?.price ?? finalPrice;

    final purchasedItem = ProfileItem(
      id: realOrderNumber.isNotEmpty
          ? realOrderNumber
          : (item.id.isNotEmpty
                ? item.id
                : DateTime.now().millisecondsSinceEpoch.toString()),
      imageUrl: item.imagePath,
      price: realPrice,
      likes: 1200,
      isSold: true,
      brand: item.brand.isNotEmpty ? item.brand : item.itemName,
      itemName: item.itemName,
      status: "Reserved",
      images: item.itemImages,
    );

    // Add purchased item to profile
    try {
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      final profileController = Get.find<ProfileController>();
      profileController.rxPurchaseItems.insert(0, purchasedItem);
    } catch (_) {}

    return purchasedItem;
  }
}
