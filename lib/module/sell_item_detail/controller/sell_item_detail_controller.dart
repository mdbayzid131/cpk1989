import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class SellItemDetailController extends GetxController {
  late final ProfileItem item;
  final rxCurrentPage = 0.obs;
  late final PageController pageController;

  final rxIsEditMode = true.obs;
  final rxStep = 1.obs;
  late final TextEditingController titleController;
  late final TextEditingController brandController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController conditionController;
  late final TextEditingController sellerNameController;
  late final TextEditingController sellerLocationController;
  late final TextEditingController sellerCountryController;
  late final TextEditingController sellerPhoneController;

  final rxTitle = "".obs;
  final rxBrand = "".obs;
  final rxDescription = "".obs;
  final rxPrice = "".obs;
  final rxCondition = "".obs;
  final rxSellerName = "".obs;
  final rxSellerLocation = "".obs;
  final rxSellerCountry = "".obs;
  final rxSellerPhone = "".obs;
  final rxOriginalPackaging = false.obs;
  final rxBillName = "".obs;

  // Payment method variables
  final rxHasPaymentMethod = false.obs;
  final rxSelectedCardIndex = 1.obs; // Index 1 is Visa Card by default
  final rxCards = <Map<String, String>>[
    {
      'type': 'Card',
      'logo': 'card',
      'cardNumber': 'Card',
      'expiry': 'Exp 12/29',
    },
    {
      'type': 'Visa Card',
      'logo': 'visa',
      'cardNumber': '**** **** **** 4526',
      'expiry': 'Exp 08/28',
    },
    {
      'type': 'Master Card',
      'logo': 'mastercard',
      'cardNumber': '**** **** **** 4526',
      'expiry': 'Exp 08/28',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.88);

    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: false,
        brand: "Channel",
        itemName: "Classic Flap Bag",
        status: null,
      );
    }

    final isFallback = item.id == 'fallback';

    titleController = TextEditingController(
      text: isFallback ? "Classic Flap Bag" : item.itemName,
    );
    brandController = TextEditingController(
      text: isFallback ? "Channel" : item.brand,
    );
    descriptionController = TextEditingController(
      text:
          "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
    );
    priceController = TextEditingController(
      text: isFallback ? "3200" : item.price.toInt().toString(),
    );
    conditionController = TextEditingController(text: "Excellent");
    sellerNameController = TextEditingController(text: "Olivia Mendes");
    sellerLocationController = TextEditingController(
      text: "Palm Jumeirah, Building 5, Apt 1204",
    );
    sellerCountryController = TextEditingController(text: "Dubai, UAE");
    sellerPhoneController = TextEditingController(text: "(+971) 50 123 4567");

    rxTitle.value = titleController.text;
    rxBrand.value = brandController.text;
    rxDescription.value = descriptionController.text;
    rxPrice.value = priceController.text;
    rxCondition.value = conditionController.text;
    rxSellerName.value = sellerNameController.text;
    rxSellerLocation.value = sellerLocationController.text;
    rxSellerCountry.value = sellerCountryController.text;
    rxSellerPhone.value = sellerPhoneController.text;

    // Listen to changes in controllers to keep rx variables in sync
    titleController.addListener(() {
      rxTitle.value = titleController.text;
    });
    brandController.addListener(() {
      rxBrand.value = brandController.text;
    });
    priceController.addListener(() {
      rxPrice.value = priceController.text;
    });
    descriptionController.addListener(() {
      rxDescription.value = descriptionController.text;
    });
    conditionController.addListener(() {
      rxCondition.value = conditionController.text;
    });
    sellerNameController.addListener(() {
      rxSellerName.value = sellerNameController.text;
    });
    sellerLocationController.addListener(() {
      rxSellerLocation.value = sellerLocationController.text;
    });
    sellerCountryController.addListener(() {
      rxSellerCountry.value = sellerCountryController.text;
    });
    sellerPhoneController.addListener(() {
      rxSellerPhone.value = sellerPhoneController.text;
    });
  }

  void toggleEditMode() {
    // Edit mode is always true
  }

  @override
  void onClose() {
    pageController.dispose();
    titleController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    conditionController.dispose();
    sellerNameController.dispose();
    sellerLocationController.dispose();
    sellerCountryController.dispose();
    sellerPhoneController.dispose();
    super.onClose();
  }
}
