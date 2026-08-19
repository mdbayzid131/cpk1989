import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/repositories/wishlist_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class WishlistItem {
  final String id;
  final String imageUrl;
  final double price;
  final String brand;
  final String itemName;
  final String? description;
  final String? condition;
  final ProductModel? rawProduct;

  WishlistItem({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.brand,
    required this.itemName,
    this.description,
    this.condition,
    this.rawProduct,
  });

  factory WishlistItem.fromProductModel(ProductModel product) {
    return WishlistItem(
      id: product.id ?? '',
      imageUrl: (product.images != null && product.images!.isNotEmpty)
          ? product.images!.first
          : '',
      price: product.price ?? 0.0,
      brand: product.brand ?? 'BRAND',
      itemName: product.name ?? 'Item Name',
      description: product.description,
      condition: product.condition,
      rawProduct: product,
    );
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('product') && json['product'] is Map) {
      final product = ProductModel.fromJson(json['product']);
      return WishlistItem.fromProductModel(product);
    }
    final product = ProductModel.fromJson(json);
    return WishlistItem.fromProductModel(product);
  }
}

class WishlistController extends GetxController {
  late final WishlistRepository _wishlistRepo;

  final rxItems = <WishlistItem>[].obs;
  final rxRemovingIds = <String>[].obs;
  final rxIsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ApiClient>()) {
      _wishlistRepo = WishlistRepository(apiClient: Get.find<ApiClient>());
    } else {
      _wishlistRepo = WishlistRepository(apiClient: Get.put(ApiClient()));
    }
    fetchWishlist();
  }

  /// 1. Fetch Wishlist Items: GET /wishlist
  Future<void> fetchWishlist() async {
    rxIsLoading.value = true;
    try {
      final response = await _wishlistRepo.getWishlist();
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'] ?? response.data;
        if (rawData is List) {
          final items = rawData
              .map((e) => WishlistItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          rxItems.assignAll(items);
        }
      }
    } catch (e) {
      Helpers.debug("Fetch wishlist error: $e");
    } finally {
      rxIsLoading.value = false;
    }
  }

  /// 2. Toggle / Remove Item from Wishlist: DELETE /wishlist/:productId
  Future<void> toggleFavorite(String id) async {
    if (rxRemovingIds.contains(id)) return;
    rxRemovingIds.add(id);

    try {
      final response = await _wishlistRepo.removeFromWishlist(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        rxItems.removeWhere((item) => item.id == id);
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
      } else {
        // Fallback optimistic removal
        rxItems.removeWhere((item) => item.id == id);
      }
    } catch (e) {
      rxItems.removeWhere((item) => item.id == id);
    } finally {
      rxRemovingIds.remove(id);
    }
  }

  /// 3. Add Item to Wishlist: POST /wishlist/:productId
  Future<bool> addToWishlist(ProductModel product) async {
    final productId = product.id;
    if (productId == null || productId.isEmpty) return false;

    try {
      final response = await _wishlistRepo.addToWishlist(productId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newItem = WishlistItem.fromProductModel(product);
        if (!rxItems.any((item) => item.id == productId)) {
          rxItems.add(newItem);
        }
        return true;
      }
    } catch (e) {
      Helpers.debug("Add to wishlist error: $e");
    }
    return false;
  }
}
