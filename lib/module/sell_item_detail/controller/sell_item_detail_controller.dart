import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class SellItemDetailController extends GetxController {
  late final ProfileItem item;

  final rxIsEditMode = false.obs;
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

    brandController = TextEditingController(text: item.brand);
    descriptionController = TextEditingController(
      text:
          "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
    );
    priceController = TextEditingController(
      text: item.price.toInt().toString(),
    );
    conditionController = TextEditingController(text: "Excellent");
    rxCondition.value = "Excellent";
    rxPrice.value = priceController.text;
    rxBrand.value = item.brand;
    rxDescription.value = descriptionController.text;
    rxDescriptionLength.value = descriptionController.text.length;
  }

  void toggleEditMode() {
    if (rxIsEditMode.value) {
      // Save changes
      rxBrand.value = brandController.text;
      rxDescription.value = descriptionController.text;
      rxPrice.value = priceController.text;
      rxCondition.value = conditionController.text;
    }
    rxIsEditMode.value = !rxIsEditMode.value;
  }

  @override
  void onClose() {
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    conditionController.dispose();
    super.onClose();
  }
}
