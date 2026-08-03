import 'package:get/get.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/config/routes/app_pages.dart';

class FeedItem {
  final String id;
  final String imagePath;
  final String userName;
  final String condition;
  final String itemName;
  final String price;
  final bool isVerified;
  final String size;
  final String wornCount;
  final String description;
  final List<String>? images;
  final bool originalPackagingAvailable;
  final String sellerProfileImage;
  final String? proofOfPurchase;

  FeedItem({
    this.id = '',
    required this.imagePath,
    required this.userName,
    required this.condition,
    required this.itemName,
    required this.price,
    required this.size,
    required this.wornCount,
    required this.description,
    this.isVerified = true,
    this.images,
    this.originalPackagingAvailable = false,
    this.sellerProfileImage = '',
    this.proofOfPurchase,
  });

  List<String> get itemImages =>
      images ?? [imagePath, imagePath, imagePath];

  factory FeedItem.fromProductModel(ProductModel product) {
    final double rawPrice = product.price ?? 0.0;
    final formattedPrice = "AED ${rawPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}";

    return FeedItem(
      id: product.id ?? '',
      imagePath: (product.images != null && product.images!.isNotEmpty)
          ? product.images!.first
          : '',
      userName: product.seller?.name ?? 'Unknown',
      condition: product.condition ?? 'Unknown',
      itemName: product.name ?? 'Luxury Item',
      price: formattedPrice,
      size: 'Standard',
      wornCount: product.originalPackagingAvailable == true ? 'With Packaging' : 'Item Only',
      description: product.description ?? '',
      isVerified: true,
      images: product.images,
      originalPackagingAvailable: product.originalPackagingAvailable ?? false,
      sellerProfileImage: product.seller?.profileImage ?? '',
      proofOfPurchase: product.proofOfPurchase,
    );
  }
}

class HomeController extends GetxController {
  final ProductRepository _productRepo = Get.find<ProductRepository>();

  final rxItems = <FeedItem>[].obs;
  final rxIsLoading = false.obs;

  int _currentPage = 1;
  int _totalPage = 1;
  bool _isFetchingNextPage = false;

  @override
  void onInit() {
    super.onInit();
    fetchFeedItems(refresh: true);
  }

  Future<void> fetchFeedItems({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _totalPage = 1;
      rxItems.clear();
    }

    if (_currentPage > _totalPage) return;
    if (_isFetchingNextPage) return;

    _isFetchingNextPage = true;
    if (refresh) rxIsLoading.value = true;

    try {
      final response = await _productRepo.getProducts(
        page: _currentPage,
        limit: 10,
        status: 'available', // only display available items
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List list = data['data'];
          final List<FeedItem> newItems = list.map((itemJson) {
            final product = ProductModel.fromJson(itemJson);
            return FeedItem.fromProductModel(product);
          }).toList();

          rxItems.addAll(newItems);

          if (data['pagination'] != null) {
            _totalPage = data['pagination']['totalPage'] ?? 1;
          }
          _currentPage++;
        }
      }
    } catch (e) {
      Helpers.debug("Error fetching products: $e");
    } finally {
      _isFetchingNextPage = false;
      rxIsLoading.value = false;
    }
  }

  void onPageChanged(int index) {
    // When the user approaches the end of the loaded list, fetch the next page
    if (index >= rxItems.length - 2) {
      fetchFeedItems();
    }
  }

  Future<void> viewProductDetails(FeedItem item) async {
    Helpers.showLoadingDialog(message: "Loading details...");
    try {
      final response = await _productRepo.getProductById(item.id);
      Helpers.hideLoadingDialog();
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final product = ProductModel.fromJson(data);
          final detailedItem = FeedItem.fromProductModel(product);
          Get.toNamed(
            AppRoutes.itemDetail,
            arguments: detailedItem,
          );
          return;
        }
      }
      // Fallback
      Get.toNamed(
        AppRoutes.itemDetail,
        arguments: item,
      );
    } catch (e) {
      Helpers.hideLoadingDialog();
      // Fallback
      Get.toNamed(
        AppRoutes.itemDetail,
        arguments: item,
      );
    }
  }
}
