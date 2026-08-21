import 'package:cpk1989/core/utils/helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
import 'package:cpk1989/core/services/payment_service.dart';
import 'package:cpk1989/core/widgets/payment_error_bottom_sheet.dart';

class SecureCheckoutController extends GetxController {
  late final FeedItem item;
  String? lastErrorMessage;

  // Gesture Recognizers for checkout footer links
  late final TapGestureRecognizer termsRecognizer;
  late final TapGestureRecognizer purchasePolicyRecognizer;

  // Form Field Controllers
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController locationController;
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

  // Inline validation states
  final rxLocationError = "".obs;
  final rxPhoneError = "".obs;

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

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    locationController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();

    locationController.addListener(() {
      if (rxLocationError.value.isNotEmpty &&
          locationController.text.trim().isNotEmpty) {
        rxLocationError.value = "";
      }
    });
    addressController.addListener(() {
      if (rxLocationError.value.isNotEmpty &&
          addressController.text.trim().isNotEmpty) {
        rxLocationError.value = "";
      }
    });
    phoneController.addListener(() {
      if (rxPhoneError.value.isNotEmpty &&
          phoneController.text.trim().isNotEmpty) {
        rxPhoneError.value = "";
      }
    });

    try {
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController(), permanent: true);
      }
      final profileCtrl = Get.find<ProfileController>();
      syncFromProfile(profileCtrl);

      // Fetch fresh profile from API & sync
      profileCtrl.fetchUserProfile().then((_) {
        syncFromProfile(profileCtrl);
      });
    } catch (e) {
      debugPrint("⚠️ Sync profile in checkout error: $e");
    }
  }

  void setPhoneAndCode(String rawPhone) {
    if (rawPhone.trim().isEmpty) return;

    final codes = [
      "+971",
      "+880",
      "+966",
      "+974",
      "+965",
      "+968",
      "+973",
      "+44",
      "+1",
    ];

    String clean = rawPhone.trim();
    String foundCode = "";

    bool matched = true;
    while (matched) {
      matched = false;
      for (final code in codes) {
        if (clean.startsWith(code)) {
          foundCode = code;
          clean = clean.substring(code.length).trim();
          matched = true;
          break;
        }
      }
    }

    if (foundCode.isNotEmpty) {
      rxPhoneCode.value = foundCode;
    }

    for (final c in codes) {
      clean = clean.replaceAll(c, '').trim();
    }
    phoneController.text = clean.trim();
  }

  String get formattedFullPhone {
    final code = rxPhoneCode.value.trim();
    String digitsOnly = phoneController.text.trim();
    final codes = [
      "+971",
      "+880",
      "+966",
      "+974",
      "+965",
      "+968",
      "+973",
      "+44",
      "+1",
    ];
    for (final c in codes) {
      digitsOnly = digitsOnly.replaceAll(c, '').trim();
    }
    return code.isNotEmpty ? '$code $digitsOnly' : digitsOnly;
  }

  void syncFromProfile(ProfileController profileCtrl) {
    firstNameController.text = profileCtrl.firstNameController.text;
    lastNameController.text = profileCtrl.lastNameController.text;
    
    final locVal = profileCtrl.locationController.text.isNotEmpty
        ? profileCtrl.locationController.text
        : (profileCtrl.addressController.text.isNotEmpty
            ? profileCtrl.addressController.text
            : '');
    locationController.text = locVal;
    addressController.text = locVal;

    if (profileCtrl.rxPhoneCode.value.isNotEmpty) {
      rxPhoneCode.value = profileCtrl.rxPhoneCode.value;
    }

    final fullPhone = profileCtrl.fullPhone.trim();
    if (fullPhone.isNotEmpty) {
      setPhoneAndCode(fullPhone);
    }

    final countryVal = profileCtrl.countryController.text.isNotEmpty
        ? profileCtrl.countryController.text
        : (profileCtrl.rxLocation.value.isNotEmpty
            ? profileCtrl.rxLocation.value
            : "UAE");
    rxLocation.value = countryVal;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    locationController.dispose();
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
    rxLocationError.value = "";
    rxPhoneError.value = "";

    bool isValid = true;

    final locText = locationController.text.trim().isNotEmpty
        ? locationController.text.trim()
        : addressController.text.trim();

    if (locText.isEmpty) {
      rxLocationError.value = "Location / Address is required.";
      isValid = false;
    }

    if (phoneController.text.trim().isEmpty) {
      rxPhoneError.value = "Phone number is required.";
      isValid = false;
    }

    return isValid;
  }

  Future<ProfileItem?> processPurchase() async {
    if (!validateDeliveryDetails()) return null;

    if (rxPaymentMethod.value == "card" &&
        profileController.rxSavedCards.isEmpty) {
      return null;
    }

    final fullPhone = formattedFullPhone;
    final cityInput = locationController.text.trim();
    final countrySelected = rxLocation.value;
    final addressText = cityInput.isNotEmpty ? cityInput : countrySelected;

    // 1. Sync delivery details to user profile backend API & local storage FIRST
    // Profile's location gets cityInput, Profile's country gets countrySelected
    try {
      await profileController.updateDeliveryDetailsFromCheckout(
        address: addressText,
        country: countrySelected,
        phone: fullPhone,
      );
    } catch (e) {
      debugPrint('⚠️ Error syncing profile delivery details: $e');
    }

    double finalPrice = 3200.0;
    try {
      finalPrice = double.parse(item.price.replaceAll(',', ''));
    } catch (_) {}

    final selectedCardId = rxSelectedCardId.value.isNotEmpty
        ? rxSelectedCardId.value
        : (profileController.rxSavedCards.isNotEmpty
              ? profileController.rxSavedCards.first.id
              : null);

    try {
      final paymentResult = await PaymentService.to.processPayment(
        paymentMethod: rxPaymentMethod.value,
        productId: item.id.isNotEmpty ? item.id : 'unknown',
        address: addressText,
        location: countrySelected,
        phone: fullPhone,
        selectedPaymentMethodId: selectedCardId,
      );

      if (!paymentResult.success) {
        if (!paymentResult.isCancelled) {
          lastErrorMessage =
              paymentResult.errorMessage ??
              "Payment could not be completed. Please try again.";
        } else {
          lastErrorMessage = null;
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
    } catch (e) {
      debugPrint('❌ processPurchase unexpected error: $e');
      lastErrorMessage = "An unexpected error occurred. Please try again.";
      return null;
    } finally {
      rxIsProcessing.value = false;
    }
  }

  void showPaymentErrorDialog(String errorMsg, {BuildContext? context}) {
    final ctx = context ?? Get.context;
    if (ctx != null) {
      showPaymentErrorBottomSheet(
        context: ctx,
        errorMessage: errorMsg,
      );
    }
  }
}
