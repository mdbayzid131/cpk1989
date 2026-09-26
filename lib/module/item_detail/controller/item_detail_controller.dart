import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/wishlist/controller/wishlist_controller.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';

class ItemDetailController extends GetxController {
  late final Rx<FeedItem> rxFeedItem;
  final rxProductModel = Rxn<ProductModel>();
  final rxIsFavorite = false.obs;
  final rxCurrentPage = 0.obs;
  final rxIsLoading = false.obs;

  FeedItem get item => rxFeedItem.value;

  ProductRepository get _productRepo {
    if (!Get.isRegistered<ProductRepository>()) {
      final apiClient = Get.isRegistered<ApiClient>()
          ? Get.find<ApiClient>()
          : Get.put(ApiClient());
      Get.put(ProductRepository(apiClient: apiClient));
    }
    return Get.find<ProductRepository>();
  }

  @override
  void onInit() {
    super.onInit();
    FeedItem initialItem;
    if (Get.arguments is FeedItem) {
      initialItem = Get.arguments as FeedItem;
    } else if (Get.arguments is String) {
      initialItem = FeedItem(
        id: Get.arguments as String,
        imagePath: '',
        userName: 'Seller',
        condition: 'Unknown',
        itemName: 'Luxury Item',
        price: 'N/A',
        wornCount: 'N/A',
        size: 'N/A',
        description: 'Loading details...',
      );
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      initialItem = FeedItem(
        id: map['productId']?.toString() ?? map['id']?.toString() ?? '',
        imagePath: '',
        userName: 'Seller',
        condition: 'Unknown',
        itemName: 'Luxury Item',
        price: 'N/A',
        wornCount: 'N/A',
        size: 'N/A',
        description: 'Loading details...',
      );
    } else {
      initialItem = FeedItem(
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
    rxFeedItem = Rx<FeedItem>(initialItem);

    if (Get.isRegistered<WishlistController>()) {
      final wishlistController = Get.find<WishlistController>();
      rxIsFavorite.value =
          wishlistController.rxItems.any((i) => i.id == initialItem.id);
    }

    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final targetId = item.id;
    if (targetId.isEmpty) return;

    rxIsLoading.value = true;
    try {
      final res = await _productRepo.getProductById(targetId);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          final prod = ProductModel.fromJson(data);
          rxProductModel.value = prod;

          final rawPrice = prod.price ?? 0;
          final formattedPrice =
              "AED ${rawPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

          rxFeedItem.value = FeedItem(
            id: prod.id ?? item.id,
            sellerId: prod.seller?.id ?? item.sellerId,
            imagePath: (prod.images != null && prod.images!.isNotEmpty)
                ? prod.displayFirstImage
                : item.imagePath,
            userName:
                (prod.seller?.name != null && prod.seller!.name!.isNotEmpty)
                    ? prod.seller!.name!
                    : item.userName,
            condition: prod.condition ?? item.condition,
            itemName: prod.name ?? item.itemName,
            brand: prod.brand ?? item.brand,
            price: formattedPrice,
            size: item.size,
            wornCount: item.wornCount,
            description: prod.description ?? item.description,
            isVerified: item.isVerified,
            images: prod.displayImages.isNotEmpty
                ? prod.displayImages
                : item.itemImages,
            sellerProfileImage: prod.seller?.displayProfileImage ??
                item.sellerProfileImage,
            proofOfPurchase: prod.proofOfPurchase ?? item.proofOfPurchase,
            originalPackagingAvailable:
                prod.originalPackagingAvailable ??
                item.originalPackagingAvailable,
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ ItemDetailController fetchProductDetails error: $e");
    } finally {
      rxIsLoading.value = false;
    }
  }

  void toggleFavorite() {
    rxIsFavorite.value = !rxIsFavorite.value;
    if (Get.isRegistered<WishlistController>()) {
      final wishlistController = Get.find<WishlistController>();
      if (rxIsFavorite.value) {
        if (item.id.isNotEmpty) {
          wishlistController.addToWishlist(
            ProductModel(
              id: item.id,
              name: item.itemName,
              brand: item.brand,
              images: [item.imagePath],
              price: double.tryParse(
                item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
              ),
            ),
          );
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
