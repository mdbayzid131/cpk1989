import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cpk1989/core/utils/helpers.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/data/models/user_model.dart';
import 'package:cpk1989/data/models/product_model.dart';
import 'package:cpk1989/data/models/order_model.dart';
import 'package:cpk1989/data/models/saved_card_model.dart';
import 'package:cpk1989/data/models/profile_stats_model.dart';
import 'package:cpk1989/data/repositories/user_repository.dart';
import 'package:cpk1989/data/repositories/payment_repository.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/core/services/payment_service.dart';

class ProfileItem {
  final String id;
  final String imageUrl;
  final double price;
  final int likes;
  final bool isSold;
  final String brand;
  final String itemName;
  final String? status;
  final List<String>? images;
  final String? proofOfPurchase;
  final bool? originalPackagingAvailable;
  final OrderModel? orderModel;

  ProfileItem({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.likes,
    required this.isSold,
    required this.brand,
    required this.itemName,
    this.status,
    this.images,
    this.proofOfPurchase,
    this.originalPackagingAvailable,
    this.orderModel,
  });

  List<String> get itemImages => images ?? [imageUrl, imageUrl, imageUrl];

  String get displayStatus {
    final st = (status ?? '').toLowerCase();
    if (st == 'secured' ||
        st == 'reserved' ||
        st == 'pending' ||
        st == 'pending_payment') {
      return 'Reserved';
    }
    if (st == 'collected' || st == 'in_transit') {
      return 'Collected';
    }
    if (st == 'authenticating') {
      return 'Authenticating';
    }
    if (st == 'delivered' || st == 'completed') {
      return 'Delivered';
    }
    if (st == 'cancelled') {
      return 'Cancelled';
    }
    // Unknown status: show capitalised raw value
    return st.isNotEmpty ? (st[0].toUpperCase() + st.substring(1)) : 'Reserved';
  }
}

class ProfileController extends GetxController {
  final rxSelectedIndex = 0.obs;
  final rxIsEditing = false.obs;
  final rxIsLoadingProfile = false.obs;
  final rxIsLoadingWardrobe = false.obs;
  final rxIsLoadingOrders = false.obs;
  final rxOrdersPage = 1.obs;
  final rxOrdersTotalPages = 1.obs;
  final rxHasMoreOrders = true.obs;
  final rxIsLoadingMoreOrders = false.obs;

  final rxWardrobeItems = <ProfileItem>[].obs;
  final rxPurchaseItems = <ProfileItem>[].obs;
  final rxSavedCards = <SavedCardModel>[].obs;
  RxList<SavedCardModel> get rxCards => rxSavedCards;
  final rxIsLoadingCards = false.obs;

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController addressController;
  late final TextEditingController locationController;
  late final TextEditingController countryController;
  late final TextEditingController phoneController;
  final rxPhoneCode = "+971".obs;

  String get fullPhone {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) return '';
    if (phone.startsWith('+')) return phone;
    return '${rxPhoneCode.value} $phone'.trim();
  }
  final rxLocation = "".obs;
  final rxUserName = "".obs;
  final rxUserId = "".obs;
  final rxProfileImage = "".obs;
  final rxUserProfile = Rxn<UserModel>();
  final rxProfileStats = ProfileStatsModel().obs;

  UserRepository get _userRepo => Get.find<UserRepository>();
  ProductRepository get _productRepo => Get.find<ProductRepository>();

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController(text: "");
    lastNameController = TextEditingController(text: "");
    addressController = TextEditingController(text: "");
    locationController = TextEditingController(text: "");
    countryController = TextEditingController(text: "");
    phoneController = TextEditingController(text: "");

    _loadUserData();
    fetchProfileApiData();
  }

  /// Main API loader for Profile, Stats, Wardrobe & Purchases
  Future<void> fetchProfileApiData() async {
    await fetchUserProfile();
    await fetchProfileStats();
    if (rxUserId.value.isNotEmpty) {
      await fetchMyWardrobe();
    }
    await fetchMyPurchases();
    await fetchSavedCards();
  }

  /// Fetch profile statistics from GET /user/profile/stats
  Future<void> fetchProfileStats() async {
    try {
      final response = await _userRepo.getProfileStats();
      if (response.statusCode == 200 && response.data != null) {
        rxProfileStats.value = ProfileStatsModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('⚠️ Fetch profile stats error: $e');
    }
  }

  /// 1. Fetch User Profile from GET /user/profile
  Future<void> fetchUserProfile() async {
    rxIsLoadingProfile.value = true;
    try {
      final response = await _userRepo.getProfile();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileResp = ProfileResponseModel.fromJson(response.data);
        final user = profileResp.data;
        if (user != null) {
          rxUserProfile.value = user;
          rxUserId.value = user.id ?? '';
          final fullName = user.name ?? '';
          if (fullName.isNotEmpty) {
            final parts = fullName.split(' ');
            firstNameController.text = parts.first;
            lastNameController.text = parts.length > 1
                ? parts.sublist(1).join(' ')
                : '';
            rxUserName.value = fullName;
          }
          if (user.phone != null &&
              user.phone!.isNotEmpty &&
              user.phone != "50 123 4567") {
            setPhoneAndCode(user.phone!);
          } else if (phoneController.text == "50 123 4567") {
            phoneController.text = "";
          }
          if (user.address != null && user.address!.isNotEmpty) {
            addressController.text = user.address!;
          }
          if (user.location != null && user.location!.isNotEmpty) {
            locationController.text = user.location!;
          }
          if (user.country != null && user.country!.isNotEmpty) {
            countryController.text = user.country!;
          }

          final locStr = user.location ?? '';
          final countryStr = user.country ?? '';
          final loc = (locStr.isNotEmpty && countryStr.isNotEmpty)
              ? (locStr.contains(countryStr) ? locStr : '$locStr, $countryStr')
              : locStr.isNotEmpty
              ? locStr
              : countryStr;
          rxLocation.value = loc;

          if (user.displayImage.isNotEmpty) {
            rxProfileImage.value = user.displayImage;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetch profile error: $e');
    } finally {
      rxIsLoadingProfile.value = false;
    }
  }

  /// 2. Fetch User Wardrobe from GET /products?seller={userId}
  Future<void> fetchMyWardrobe() async {
    if (rxUserId.value.isEmpty) {
      await fetchUserProfile();
    }
    if (rxUserId.value.isEmpty) {
      rxIsLoadingWardrobe.value = false;
      return;
    }

    rxIsLoadingWardrobe.value = true;
    try {
      final response = await _userRepo.getMyWardrobe(sellerId: rxUserId.value);
      if (response.statusCode == 200) {
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
            proofOfPurchase: prod.proofOfPurchase,
            originalPackagingAvailable: prod.originalPackagingAvailable,
          );
        }).toList();

        rxWardrobeItems.assignAll(items);
      }
    } catch (e) {
      debugPrint('⚠️ Fetch wardrobe error: $e');
    } finally {
      rxIsLoadingWardrobe.value = false;
    }
  }

  /// 3. Fetch User Purchases / Orders from GET /orders with pagination
  Future<void> fetchMyPurchases({bool refresh = false}) async {
    if (refresh || rxPurchaseItems.isEmpty) {
      rxOrdersPage.value = 1;
      rxHasMoreOrders.value = true;
      rxIsLoadingOrders.value = true;
    }

    try {
      final response = await _userRepo.getMyOrders(
        page: rxOrdersPage.value,
        limit: 10,
      );
      if (response.statusCode == 200) {
        final List list = response.data['data'] ?? [];
        final List<ProfileItem> items = [];

        for (var json in list) {
          try {
            final map = Map<String, dynamic>.from(json);
            final order = OrderModel.fromJson(map);
            final prod = order.productModel;
            final img = (prod?.images != null && prod!.images!.isNotEmpty)
                ? prod.images!.first
                : '';
            final rootStatus =
                (map['status'] ?? order.status ?? prod?.status ?? 'secured')
                    .toString();

            items.add(
              ProfileItem(
                id: order.id ?? '',
                imageUrl: img,
                price: order.price ?? prod?.price ?? 0.0,
                likes: 1200,
                isSold: true,
                brand: prod?.brand ?? 'LUXURY',
                itemName: prod?.name ?? order.orderNumber ?? 'Order',
                status: rootStatus,
                images: prod?.images,
                proofOfPurchase: prod?.proofOfPurchase,
                originalPackagingAvailable: prod?.originalPackagingAvailable,
                orderModel: order,
              ),
            );
          } catch (itemErr) {
            debugPrint('⚠️ Error parsing order item: $itemErr');
          }
        }

        final pagination = response.data['pagination'];
        if (pagination != null) {
          final totalPage = pagination['totalPage'] ?? 1;
          rxOrdersTotalPages.value = totalPage;
          rxHasMoreOrders.value = rxOrdersPage.value < totalPage;
        }

        rxPurchaseItems.assignAll(items);
      }
    } catch (e) {
      debugPrint('⚠️ Fetch purchases error: $e');
    } finally {
      rxIsLoadingOrders.value = false;
    }
  }

  /// Load next page of purchases
  Future<void> loadMorePurchases() async {
    if (rxIsLoadingOrders.value ||
        rxIsLoadingMoreOrders.value ||
        !rxHasMoreOrders.value) {
      return;
    }

    rxIsLoadingMoreOrders.value = true;
    try {
      final nextPage = rxOrdersPage.value + 1;
      final response = await _userRepo.getMyOrders(page: nextPage, limit: 10);

      if (response.statusCode == 200) {
        final List list = response.data['data'] ?? [];
        final List<ProfileItem> newItems = [];

        for (var json in list) {
          try {
            final map = Map<String, dynamic>.from(json);
            final order = OrderModel.fromJson(map);
            final prod = order.productModel;
            final img = (prod?.images != null && prod!.images!.isNotEmpty)
                ? prod.images!.first
                : '';
            final rootStatus =
                (map['status'] ?? order.status ?? prod?.status ?? 'secured')
                    .toString();

            newItems.add(
              ProfileItem(
                id: order.id ?? '',
                imageUrl: img,
                price: order.price ?? prod?.price ?? 0.0,
                likes: 1200,
                isSold: true,
                brand: prod?.brand ?? 'LUXURY',
                itemName: prod?.name ?? order.orderNumber ?? 'Order',
                status: rootStatus,
                images: prod?.images,
                proofOfPurchase: prod?.proofOfPurchase,
                originalPackagingAvailable: prod?.originalPackagingAvailable,
                orderModel: order,
              ),
            );
          } catch (itemErr) {
            debugPrint('⚠️ Error parsing order item: $itemErr');
          }
        }

        rxPurchaseItems.addAll(newItems);
        rxOrdersPage.value = nextPage;

        final pagination = response.data['pagination'];
        if (pagination != null) {
          final totalPage = pagination['totalPage'] ?? 1;
          rxOrdersTotalPages.value = totalPage;
          rxHasMoreOrders.value = nextPage < totalPage;
        } else {
          rxHasMoreOrders.value = newItems.isNotEmpty;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Load more purchases error: $e');
    } finally {
      rxIsLoadingMoreOrders.value = false;
    }
  }

  /// 4. Fetch Saved Cards from GET /payment-methods
  Future<void> fetchSavedCards() async {
    rxIsLoadingCards.value = true;
    try {
      final paymentRepo = Get.find<PaymentRepository>();
      final page = await paymentRepo.getPaymentMethods();
      rxSavedCards.assignAll(page.paymentMethods);
    } catch (e) {
      debugPrint('⚠️ Fetch saved cards error: $e');
    } finally {
      rxIsLoadingCards.value = false;
    }
  }

  /// Add a new card via SetupIntent and refresh saved cards list
  Future<void> addNewCard() async {
    final result = await PaymentService.to.addCardWithSetupIntent();
    if (result.success) {
      Get.snackbar(
        'Success',
        'Card saved successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      await fetchSavedCards();
    } else if (!result.isCancelled && result.errorMessage != null) {
      Get.snackbar(
        'Card Error',
        result.errorMessage!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Delete a saved card by ID
  Future<void> deleteSavedCard(String cardId) async {
    try {
      final paymentRepo = Get.find<PaymentRepository>();
      await paymentRepo.deletePaymentMethod(cardId);
      rxSavedCards.removeWhere((card) => card.id == cardId);
      Get.snackbar(
        'Success',
        'Card removed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('⚠️ Delete card error: $e');
      rxSavedCards.removeWhere((card) => card.id == cardId);
    }
  }

  /// Delete a product listing from My Wardrobe (DELETE /products/:id)
  Future<bool> deleteWardrobeItem(ProfileItem item) async {
    // Check if item is reserved or sold
    final status = (item.status ?? '').toLowerCase();
    if (status == 'secured' || status == 'sold') {
      Get.snackbar(
        'Action Blocked',
        'Reserved or sold items cannot be deleted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: const Color(0xFFFF453A),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      Helpers.showLoadingDialog(message: "Deleting item...");
      final response = await _productRepo.deleteProduct(item.id);
      Get.back(); // Dismiss loading

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        rxWardrobeItems.removeWhere((i) => i.id == item.id);
        Get.snackbar(
          'Success',
          'Item deleted from wardrobe successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        fetchProfileStats(); // Update listed stats count
        return true;
      } else {
        final msg = response.data?['message'] ?? 'Failed to delete item';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: const Color(0xFFFF453A),
        );
        return false;
      }
    } catch (e) {
      Get.back(); // Dismiss loading if open
      debugPrint('⚠️ Delete product error: $e');
      Get.snackbar(
        'Error',
        'Unable to delete item. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: const Color(0xFFFF453A),
      );
      return false;
    }
  }

  /// Update product details (PATCH /products/:id)
  Future<bool> updateWardrobeItem(
    String productId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      Helpers.showLoadingDialog(message: "Updating item...");
      final response = await _productRepo.updateProduct(productId, updatedData);
      Get.back(); // Dismiss loading

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Item updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: Colors.white,
        );
        await fetchMyWardrobe();
        return true;
      } else {
        final msg = response.data?['message'] ?? 'Failed to update item';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: const Color(0xFFFF453A),
        );
        return false;
      }
    } catch (e) {
      Get.back();
      debugPrint('⚠️ Update product error: $e');
      Get.snackbar(
        'Error',
        'Unable to update item. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF161719),
        colorText: const Color(0xFFFF453A),
      );
      return false;
    }
  }

  Future<void> _loadUserData() async {
    final savedFirstName = await StorageService.getString('first_name');
    final savedLastName = await StorageService.getString('last_name');
    final savedPhone = await StorageService.getString('phone');

    if (savedFirstName.isNotEmpty) {
      firstNameController.text = savedFirstName;
    }
    if (savedLastName.isNotEmpty) {
      lastNameController.text = savedLastName;
    }
    if (savedPhone.isNotEmpty && savedPhone != "50 123 4567") {
      phoneController.text = savedPhone;
    } else if (savedPhone == "50 123 4567") {
      await StorageService.remove('phone');
      phoneController.text = "";
    }

    final fName = savedFirstName.isNotEmpty ? savedFirstName : "";
    final lName = savedLastName.isNotEmpty ? savedLastName : "";
    rxUserName.value = "$fName $lName".trim();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    locationController.dispose();
    countryController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    fetchProfileApiData();
  }

  void changeTab(int index) {
    rxSelectedIndex.value = index;
    if (index == 0) {
      fetchMyWardrobe();
    } else if (index == 1) {
      fetchMyPurchases();
    } else if (index == 2) {
      fetchUserProfile();
    }
  }

  void saveChanges({File? imageFile}) async {
    final fullName =
        "${firstNameController.text.trim()} ${lastNameController.text.trim()}"
            .trim();

    // Save to local storage
    await StorageService.setString(
      'first_name',
      firstNameController.text.trim(),
    );
    await StorageService.setString('last_name', lastNameController.text.trim());
    await StorageService.setString('phone', fullPhone);
    if (fullName.isNotEmpty) {
      rxUserName.value = fullName;
    }
    rxIsEditing.value = false;

    final body = <String, dynamic>{
      if (fullName.isNotEmpty) 'name': fullName,
      if (fullPhone.isNotEmpty) 'phone': fullPhone,
      if (addressController.text.trim().isNotEmpty)
        'address': addressController.text.trim(),
      if (locationController.text.trim().isNotEmpty)
        'location': locationController.text.trim(),
      if (countryController.text.trim().isNotEmpty)
        'country': countryController.text.trim(),
    };

    // Hit PATCH /user/profile API
    try {
      final response = await _userRepo.updateProfile(
        body,
        imageFile: imageFile,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileResp = ProfileResponseModel.fromJson(response.data);
        if (profileResp.data != null) {
          final user = profileResp.data!;
          rxUserProfile.value = user;
          if (user.displayImage.isNotEmpty) {
            rxProfileImage.value = user.displayImage;
          }
          if (user.name != null && user.name!.isNotEmpty) {
            rxUserName.value = user.name!;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Update profile API error: $e');
    }

    Get.snackbar(
      'Success',
      'Personal details updated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF161719),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
    );
  }

  void setPhoneAndCode(String rawPhone) {
    if (rawPhone.trim().isEmpty) return;

    final codes = [
      "+971",
      "+880",
      "+966",
      "+974",
      "+965",
      "+968",
      "+973",
      "+44",
      "+1",
    ];

    String clean = rawPhone.trim();
    String foundCode = "";

    bool matched = true;
    while (matched) {
      matched = false;
      for (final code in codes) {
        if (clean.startsWith(code)) {
          foundCode = code;
          clean = clean.substring(code.length).trim();
          matched = true;
          break;
        }
      }
    }

    if (foundCode.isNotEmpty) {
      rxPhoneCode.value = foundCode;
    }

    for (final c in codes) {
      clean = clean.replaceAll(c, '').trim();
    }
    phoneController.text = clean.trim();
  }

  /// Syncs delivery details entered on checkout screen to user profile backend API & local state
  Future<void> updateDeliveryDetailsFromCheckout({
    required String address,
    required String country,
    required String phone,
  }) async {
    // 1. Update ProfileController local TextControllers and Rx states
    locationController.text = address;
    countryController.text = country;
    addressController.text = address;
    if (phone.isNotEmpty) {
      setPhoneAndCode(phone);
    }
    if (country.isNotEmpty) {
      rxLocation.value = country;
    }

    // 2. Persist to local storage
    await StorageService.setString('location', address);
    await StorageService.setString('country', country);
    await StorageService.setString('address', address);
    await StorageService.setString('phone', phone);

    final fullName =
        "${firstNameController.text.trim()} ${lastNameController.text.trim()}".trim();
    final nameToUse = fullName.isNotEmpty ? fullName : rxUserName.value;

    // 3. Call backend PATCH /user/profile API
    // Profile's 'location' gets checkout address/city text
    // Profile's 'country' gets checkout country dropdown
    final body = <String, dynamic>{
      if (nameToUse.isNotEmpty) 'name': nameToUse,
      if (address.isNotEmpty) 'location': address,
      if (country.isNotEmpty) 'country': country,
      if (phone.isNotEmpty) 'phone': phone,
    };

    try {
      final response = await _userRepo.updateProfile(body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileResp = ProfileResponseModel.fromJson(response.data);
        if (profileResp.data != null) {
          rxUserProfile.value = profileResp.data!;
        }
        debugPrint(
          '✅ Delivery details successfully updated on Profile API from checkout.',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Update profile delivery details API error: $e');
    }
  }

  void deleteItem(String id) {
    rxWardrobeItems.removeWhere((item) => item.id == id);
    Get.snackbar(
      'Success',
      'Item successfully removed',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF161719),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Update Profile Picture (via Camera or Gallery)
  Future<void> updateProfileImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      Helpers.showLoadingDialog(message: "Updating profile photo...");

      final response = await _userRepo.updateProfile({}, imageFile: imageFile);

      Helpers.hideLoadingDialog();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileResp = ProfileResponseModel.fromJson(response.data);
        if (profileResp.data != null) {
          final user = profileResp.data!;
          rxUserProfile.value = user;
          if (user.displayImage.isNotEmpty) {
            rxProfileImage.value = user.displayImage;
          }
        } else if (response.data != null && response.data['data'] != null) {
          final imgUrl =
              response.data['data']['image'] ?? response.data['data']['avatar'];
          if (imgUrl != null && imgUrl.toString().isNotEmpty) {
            rxProfileImage.value = imgUrl.toString();
          }
        }

        Get.snackbar(
          'Success',
          'Profile picture updated successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF161719),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          borderRadius: 16,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Helpers.showError("Failed to update profile picture.");
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.debug("Update profile image error: $e");
      Helpers.showError("Something went wrong while updating photo.");
    }
  }
}
