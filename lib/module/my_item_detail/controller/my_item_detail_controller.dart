import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class MyItemDetailController extends GetxController {
  late final ProfileItem item;
  final rxOriginalPackaging = false.obs;
  final rxBillName = "Bill.pdf".obs;

  late final PageController pageController;
  final rxCurrentPage = 0.obs;

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
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
