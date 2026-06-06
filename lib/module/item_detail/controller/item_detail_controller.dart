import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';

class ItemDetailController extends GetxController {
  late final FeedItem item;
  final rxIsFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is FeedItem) {
      item = Get.arguments as FeedItem;
    } else {
      // Fallback to prevent layout crashes if page is accessed without args
      item = FeedItem(
        imagePath: '',
        userName: 'Unknown',
        condition: 'Unknown',
        itemName: 'Luxury Item',
        price: 'N/A',
        wornCount: 'N/A',
        size: 'N/A',
        description: 'No description available.',
      );
    }
  }

  void toggleFavorite() {
    rxIsFavorite.value = !rxIsFavorite.value;
    Get.snackbar(
      rxIsFavorite.value ? "Added to Wishlist" : "Removed from Wishlist",
      "${item.itemName} has been ${rxIsFavorite.value ? "added to" : "removed from"} your wishlist.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF161719),
      colorText: Colors.white,
    );
  }
}
