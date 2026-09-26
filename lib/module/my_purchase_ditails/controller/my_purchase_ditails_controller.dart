import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/data/models/order_model.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/repositories/user_repository.dart';

class MyPurchaseDitailsController extends GetxController {
  late final ProfileItem item;
  final rxOriginalPackaging = false.obs;
  final rxBillName = "Bill.pdf".obs;

  late final PageController pageController;
  final rxCurrentPage = 0.obs;

  final rxIsLoadingDetails = false.obs;
  final rxOrderModel = Rxn<OrderModel>();
  final rxProductModel = Rxn<ProductModel>();

  final rxSellerId = "".obs;
  final rxSellerName = "".obs;
  final rxSellerAvatar = "".obs;
  final rxIsSellerVerified = true.obs;
  final rxDescription = "".obs;
  final rxCondition = "".obs;
  final rxProofOfPurchase = Rxn<String>();
  final rxOriginalPackagingAvailable = Rxn<bool>();
  final rxLiveStatus = "".obs;
  final rxCancellationReason = "".obs;
  final rxImages = <String>[].obs;

  UserRepository get _userRepo => Get.find<UserRepository>();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.88);
    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else if (Get.arguments is String) {
      item = ProfileItem(
        id: Get.arguments as String,
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: true,
        brand: "",
        itemName: "",
        status: null,
      );
    } else if (Get.arguments is Map) {
      final map = Get.arguments as Map;
      item = ProfileItem(
        id: map['orderId']?.toString() ??
            map['id']?.toString() ??
            'fallback_purchase',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: true,
        brand: "",
        itemName: "",
        status: map['status']?.toString(),
      );
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback_purchase',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: true,
        brand: "",
        itemName: "",
        status: null,
      );
    }

    final initialSeller = item.orderModel?.sellerModel;
    final initialProdSeller = item.productModel?.seller;
    rxSellerId.value = initialSeller?.id ??
        initialProdSeller?.id ??
        item.productModel?.sellerId ??
        '';
    rxSellerName.value =
        initialSeller?.name ?? initialProdSeller?.name ?? '';
    rxSellerAvatar.value = initialSeller?.profileImage ??
        initialProdSeller?.displayProfileImage ??
        '';
    rxIsSellerVerified.value = initialSeller?.isVerified ??
        initialProdSeller?.isVerified ??
        true;

    rxLiveStatus.value = item.status ?? '';
    rxImages.assignAll(item.itemImages);
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    if (item.id.isEmpty || item.id == 'fallback_purchase') return;

    rxIsLoadingDetails.value = true;
    try {
      final response = await _userRepo.getOrderDetails(item.id);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          final order = OrderModel.fromJson(data);
          rxOrderModel.value = order;

          // Cancellation or Issue Reason
          if (data['cancellationReason'] != null &&
              data['cancellationReason'].toString().isNotEmpty) {
            rxCancellationReason.value = data['cancellationReason'].toString();
          } else if (data['note'] != null &&
              data['note'].toString().isNotEmpty) {
            rxCancellationReason.value = data['note'].toString();
          } else if (data['issue'] is Map &&
              data['issue']['reason'] != null) {
            rxCancellationReason.value = data['issue']['reason'].toString();
          }

          // Product details from backend order presenter
          if (data['product'] is Map) {
            final prodMap = Map<String, dynamic>.from(data['product']);
            final prod = ProductModel.fromJson(prodMap);
            rxProductModel.value = prod;

            if (prodMap['details'] is Map) {
              final d = prodMap['details'];
              rxDescription.value = d['description']?.toString() ?? '';
              rxCondition.value = d['condition']?.toString() ?? '';
              rxOriginalPackagingAvailable.value =
                  d['originalPackagingAvailable'] == true;
            } else {
              rxDescription.value = prod.description ?? '';
              rxCondition.value = prod.condition ?? '';
              rxOriginalPackagingAvailable.value =
                  prod.originalPackagingAvailable;
            }
            rxProofOfPurchase.value = prod.proofOfPurchase;

            if (prod.images != null && prod.images!.isNotEmpty) {
              rxImages.assignAll(prod.images!);
            }
          }

          // Seller details
          if (data['seller'] is Map) {
            final s = data['seller'];
            rxSellerId.value =
                s['_id']?.toString() ?? s['id']?.toString() ?? '';
            rxSellerName.value = s['name']?.toString() ?? '';
            rxSellerAvatar.value =
                s['profileImage']?.toString() ?? s['image']?.toString() ?? '';
            if (s['isVerified'] != null) {
              rxIsSellerVerified.value = s['isVerified'] == true;
            }
          } else if (order.sellerModel != null) {
            rxSellerId.value = order.sellerModel!.id ?? '';
            rxSellerName.value = order.sellerModel!.name ?? '';
            rxSellerAvatar.value = order.sellerModel!.profileImage ?? '';
            if (order.sellerModel!.isVerified != null) {
              rxIsSellerVerified.value =
                  order.sellerModel!.isVerified == true;
            }
          }

          if (data['status'] != null) {
            rxLiveStatus.value = data['status'].toString();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetch purchase details error: $e');
    } finally {
      rxIsLoadingDetails.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
