import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

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

  // Added Card Information
  final rxHasAddedCard = false.obs;
  final rxCardName = "".obs;
  final rxCardNumber = "".obs;
  final rxCardExpiry = "".obs;

  @override
  void onInit() {
    super.onInit();
    termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed(
          AppRoutes.termsAndPolicies,
        );
      };
    purchasePolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed(
          AppRoutes.termsAndConditions,
          arguments: "Purchase Policy",
        );
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

  void processPurchase(void Function() onFinish) {
    // Simulate purchase and add to profile purchases
    try {
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      final profileController = Get.find<ProfileController>();
      // Parse price to double
      double finalPrice = 3200.0;
      try {
        finalPrice = double.parse(item.price.replaceAll(',', ''));
      } catch (_) {}

      final purchasedItem = ProfileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: item.imagePath,
        price: finalPrice,
        likes: 1200,
        isSold: true,
        brand: "CHANEL", // Or parsed from item
        itemName: item.itemName,
        status: "Reserved",
      );

      profileController.rxPurchaseItems.insert(0, purchasedItem);
    } catch (_) {}

    Future.delayed(const Duration(seconds: 2), () {
      onFinish();
    });
  }
}
