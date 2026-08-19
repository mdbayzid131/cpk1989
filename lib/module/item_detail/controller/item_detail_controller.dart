import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/wishlist/controller/wishlist_controller.dart';
import 'package:cpk1989/data/models/product_model.dart';

class ItemDetailController extends GetxController {
  late final FeedItem item;
  final rxIsFavorite = false.obs;
  final rxCurrentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is FeedItem) {
      item = Get.arguments as FeedItem;
      if (Get.isRegistered<WishlistController>()) {
        final wishlistController = Get.find<WishlistController>();
        rxIsFavorite.value = wishlistController.rxItems.any((i) => i.id == item.id);
      }
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
    if (Get.isRegistered<WishlistController>()) {
      final wishlistController = Get.find<WishlistController>();
      if (rxIsFavorite.value) {
        if (item.id.isNotEmpty) {
          wishlistController.addToWishlist(ProductModel(
            id: item.id,
            name: item.itemName,
            brand: item.brand,
            images: [item.imagePath],
            price: double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')),
          ));
        }
      } else {
        if (item.id.isNotEmpty) {
          wishlistController.toggleFavorite(item.id);
        }
      }
    }
    Get.snackbar(
      rxIsFavorite.value ? "Added to Wishlist" : "Removed from Wishlist",
      "${item.itemName} has been ${rxIsFavorite.value ? "added to" : "removed from"} your wishlist.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF161719),
      colorText: Colors.white,
    );
  }
}
