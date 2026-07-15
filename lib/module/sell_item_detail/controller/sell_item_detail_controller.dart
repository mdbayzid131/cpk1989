import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class SellItemDetailController extends GetxController {
  late final ProfileItem item;
  final rxCurrentPage = 0.obs;
  late final PageController pageController;

  final rxIsEditMode = true.obs;
  late final TextEditingController brandController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController conditionController;
  final rxCondition = "".obs;
  final rxPrice = "".obs;
  final rxBrand = "".obs;
  final rxDescription = "".obs;
  final rxDescriptionLength = 0.obs;
  final rxBillName = "".obs;

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
        brand: "Chanel",
        itemName: "Classic Flap Bag",
        status: null,
      );
    }

    final isFallback = item.id == 'fallback';
    brandController = TextEditingController(text: isFallback ? "" : item.brand);
    descriptionController = TextEditingController(text: "");
    priceController = TextEditingController(
      text: isFallback ? "" : item.price.toInt().toString(),
    );
    conditionController = TextEditingController(text: "");

    rxCondition.value = "";
    rxPrice.value = priceController.text;
    rxBrand.value = brandController.text;
    rxDescription.value = "";
    rxDescriptionLength.value = 0;

    // Listen to changes in controllers to keep rx variables in sync
    brandController.addListener(() {
      rxBrand.value = brandController.text;
    });
    priceController.addListener(() {
      rxPrice.value = priceController.text;
    });
    descriptionController.addListener(() {
      rxDescription.value = descriptionController.text;
      rxDescriptionLength.value = descriptionController.text.length;
    });
    conditionController.addListener(() {
      rxCondition.value = conditionController.text;
    });
  }

  void toggleEditMode() {
    // Keep for potential back-compatibility, but edit mode is always true
  }

  @override
  void onClose() {
    pageController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    conditionController.dispose();
    super.onClose();
  }
}
