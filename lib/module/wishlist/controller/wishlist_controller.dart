import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistItem {
  final String id;
  final String imageUrl;
  final double price;
  final String brand;
  final String itemName;

  WishlistItem({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.brand,
    required this.itemName,
  });
}

class WishlistController extends GetxController {
  final rxItems = <WishlistItem>[].obs;
  final rxRemovingIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadItems();
  }

  void toggleFavorite(String id) {
    if (rxRemovingIds.contains(id)) return;
    rxRemovingIds.add(id);

    Future.delayed(const Duration(milliseconds: 500), () {
      rxItems.removeWhere((item) => item.id == id);
      rxRemovingIds.remove(id);

      Get.snackbar(
        'Removed',
        'Item removed from your wishlist.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void _loadItems() {
    rxItems.assignAll([
      WishlistItem(
        id: 'w1',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
      WishlistItem(
        id: 'w2',
        imageUrl:
            'https://images.unsplash.com/photo-1496747611176-843222e1e57c?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
      WishlistItem(
        id: 'w3',
        imageUrl:
            'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
      WishlistItem(
        id: 'w4',
        imageUrl:
            'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
      WishlistItem(
        id: 'w5',
        imageUrl:
            'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
      WishlistItem(
        id: 'w6',
        imageUrl:
            'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
      ),
    ]);
  }
}
