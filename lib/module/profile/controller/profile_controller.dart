import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cpk1989/core/services/storage_service.dart';

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
  });

  List<String> get itemImages =>
      images ?? [imageUrl, imageUrl, imageUrl, imageUrl];
}

class ProfileController extends GetxController {
  final rxSelectedIndex = 0.obs;
  final rxIsEditing = false.obs;
  final rxWardrobeItems = <ProfileItem>[].obs;
  final rxPurchaseItems = <ProfileItem>[].obs;
  final rxCards = <Map<String, String>>[].obs;

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  final rxLocation = "Dubai, UAE".obs;
  final rxUserName = "Gretchen Bothman".obs;

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController(text: "Gretchen");
    lastNameController = TextEditingController(text: "Bothman");
    addressController = TextEditingController(
      text: "Palm Jumeirah, Building 5, Apt 1204",
    );
    phoneController = TextEditingController(text: "50 123 4567");
    _loadUserData();
    _loadItems();
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
    if (savedPhone.isNotEmpty) {
      phoneController.text = savedPhone;
    }

    final fName = savedFirstName.isNotEmpty ? savedFirstName : "Gretchen";
    final lName = savedLastName.isNotEmpty ? savedLastName : "Bothman";
    rxUserName.value = "$fName $lName";
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    rxSelectedIndex.value = index;
  }

  void saveChanges() async {
    await StorageService.setString(
      'first_name',
      firstNameController.text.trim(),
    );
    await StorageService.setString('last_name', lastNameController.text.trim());
    await StorageService.setString('phone', phoneController.text.trim());
    rxUserName.value =
        "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
    rxIsEditing.value = false;

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

  void _loadItems() {
    rxWardrobeItems.assignAll([
      ProfileItem(
        id: '1',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "CHANEL",
        itemName: "Classic Flap Bag",
        status: null,
      ),
      ProfileItem(
        id: '2',
        imageUrl:
            'https://images.unsplash.com/photo-1496747611176-843222e1e57c?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "ZARA",
        itemName: "Satin Dress",
        status: "Reserved",
      ),
      ProfileItem(
        id: '3',
        imageUrl:
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "LOUBOUTIN",
        itemName: "Patent Heels",
        status: "Delivered",
      ),
      ProfileItem(
        id: '4',
        imageUrl:
            'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "OMEGA",
        itemName: "Speedmaster Watch",
        status: "Rejected",
      ),
      ProfileItem(
        id: '5',
        imageUrl:
            'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "ZARA",
        itemName: "Bow Heels",
      ),
      ProfileItem(
        id: '6',
        imageUrl:
            'https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "HERMÈS",
        itemName: "Birkin Bag",
      ),
      ProfileItem(
        id: '7',
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: true,
        brand: "ZARA",
        itemName: "Trench Coat",
      ),
      ProfileItem(
        id: '8',
        imageUrl:
            'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: true,
        brand: "CELINE",
        itemName: "Celine Bag",
      ),
      ProfileItem(
        id: '9',
        imageUrl:
            'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: true,
        brand: "CHANEL",
        itemName: "Chanel Bag",
      ),
    ]);

    rxPurchaseItems.assignAll([
      ProfileItem(
        id: 'p1',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Chanel Classic Flap Bag",
        status: "Reserved",
      ),
      ProfileItem(
        id: 'p2',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Chanel Classic Flap Bag",
        status: "Reserved",
      ),
      ProfileItem(
        id: 'p3',
        imageUrl:
            'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Chanel Classic Flap Bag",
        status: "Collected",
      ),
      ProfileItem(
        id: 'p4',
        imageUrl:
            'https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Chanel Classic Flap Bag",
        status: "Authenticating",
      ),
      ProfileItem(
        id: 'p5',
        imageUrl:
            'https://images.unsplash.com/photo-1627123424574-724758594e93?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Chanel Classic Flap Bag",
        status: "Delivered",
      ),
    ]);
  }
}
