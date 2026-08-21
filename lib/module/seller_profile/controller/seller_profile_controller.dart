import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/models/profile_stats_model.dart';
import 'package:cpk1989/data/repositories/user_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/core/utils/helpers.dart';

class SellerProfileController extends GetxController {
  final rxSellerId = "".obs;
  final rxUserName = "".obs;
  final rxAvatarUrl = "".obs;
  final rxIsVerified = true.obs;
  final rxIsLoading = false.obs;

  final rxItems = <ProfileItem>[].obs;
  final rxSellerStats = ProfileStatsModel().obs;

  UserRepository get _userRepo {
    if (!Get.isRegistered<UserRepository>()) {
      final apiClient = Get.isRegistered<ApiClient>()
          ? Get.find<ApiClient>()
          : Get.put(ApiClient());
      Get.put(UserRepository(apiClient: apiClient));
    }
    return Get.find<UserRepository>();
  }

  @override
  void onInit() {
    super.onInit();

    // Parse navigation arguments
    if (Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      rxSellerId.value = args['sellerId']?.toString() ?? '';
      rxUserName.value = args['userName']?.toString() ?? 'Seller';
      rxAvatarUrl.value = args['avatarUrl']?.toString() ?? '';
      rxIsVerified.value = args['isVerified'] ?? true;
    } else if (Get.arguments is String) {
      rxSellerId.value = Get.arguments as String;
      rxUserName.value = 'Seller';
    }

    fetchSellerProducts();
    fetchSellerStats();
  }

  /// Fetch seller statistics from GET /user/profile/stats/:userId
  Future<void> fetchSellerStats() async {
    if (rxSellerId.value.isEmpty) return;
    try {
      final response = await _userRepo.getProfileStats(userId: rxSellerId.value);
      if (response.statusCode == 200 && response.data != null) {
        rxSellerStats.value = ProfileStatsModel.fromJson(response.data);
      }
    } catch (e) {
      Helpers.debug("Fetch seller stats error: $e");
    }
  }

  /// Fetch seller products from GET /products?seller={sellerId}
  Future<void> fetchSellerProducts() async {
    if (rxSellerId.value.isEmpty) {
      return;
    }

    rxIsLoading.value = true;
    try {
      final response = await _userRepo.getMyWardrobe(sellerId: rxSellerId.value);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] ?? [];
        final items = list.map((json) {
          final prod = ProductModel.fromJson(json);
          return ProfileItem(
            id: prod.id ?? '',
            imageUrl: (prod.images != null && prod.images!.isNotEmpty)
                ? prod.images!.first
                : '',
            price: prod.price ?? 0.0,
            likes: 1200,
            isSold: prod.status == 'sold',
            brand: prod.brand ?? 'LUXURY',
            itemName: prod.name ?? 'Item',
            status: prod.status,
            images: prod.images,
          );
        }).toList();

        rxItems.assignAll(items);

        // Update seller name or avatar from seller object if available
        if (list.isNotEmpty) {
          final firstProd = ProductModel.fromJson(list.first);
          if (firstProd.seller != null) {
            if (rxUserName.value == 'Seller' ||
                rxUserName.value == 'Unknown' ||
                rxUserName.value.isEmpty) {
              rxUserName.value = firstProd.seller?.name ?? 'Seller';
            }
            if (rxAvatarUrl.value.isEmpty &&
                firstProd.seller?.profileImage != null) {
              rxAvatarUrl.value = firstProd.seller!.displayProfileImage;
            }
          }
        }
      }
    } catch (e) {
      Helpers.debug("Fetch seller products error: $e");
    } finally {
      rxIsLoading.value = false;
    }
  }

  int get itemsListedCount => rxItems.length;
  int get itemsSoldCount => rxItems.where((i) => i.isSold).length;

  String get closetValueFormatted {
    final totalValue = rxItems.fold<double>(0, (sum, item) => sum + item.price);
    if (totalValue >= 1000) {
      return "${(totalValue / 1000).toStringAsFixed(1)}k";
    }
    return totalValue.toInt().toString();
  }
}
