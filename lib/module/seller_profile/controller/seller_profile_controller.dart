import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class SellerProfileController extends GetxController {
  final rxUserName = "".obs;
  final rxAvatarUrl = "".obs;
  final rxIsVerified = true.obs;

  final rxItems = <ProfileItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments passed during navigation
    if (Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      rxUserName.value = args['userName'] ?? 'Gretchen Bothman';
      rxAvatarUrl.value = args['avatarUrl'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200';
      rxIsVerified.value = args['isVerified'] ?? true;
    } else if (Get.arguments is String) {
      rxUserName.value = Get.arguments as String;
      rxAvatarUrl.value = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200';
      rxIsVerified.value = true;
    } else {
      rxUserName.value = 'Gretchen Bothman';
      rxAvatarUrl.value = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200';
      rxIsVerified.value = true;
    }

    // Set specific avatar based on user name for variety
    if (rxUserName.value == "Olivia Mendes") {
      rxAvatarUrl.value = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200";
    } else if (rxUserName.value == "Sophia Rossi") {
      rxAvatarUrl.value = "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200";
    } else if (rxUserName.value == "James Miller") {
      rxAvatarUrl.value = "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200";
    }

    _loadSellerItems();
  }

  void _loadSellerItems() {
    rxItems.assignAll([
      ProfileItem(
        id: 's1',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Luxury Brand",
        itemName: "Gold Handbag",
      ),
      ProfileItem(
        id: 's2',
        imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Silk Collection",
        itemName: "Golden Silk Dress",
      ),
      ProfileItem(
        id: 's3',
        imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Italian Shoes",
        itemName: "Black High Heels",
      ),
      ProfileItem(
        id: 's4',
        imageUrl: 'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Classic Watch",
        itemName: "Luxury Watch",
      ),
      ProfileItem(
        id: 's5',
        imageUrl: 'https://images.unsplash.com/photo-1539185441755-769473a23570?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Zara",
        itemName: "Dark Red Heels",
      ),
      ProfileItem(
        id: 's6',
        imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Designer Brand",
        itemName: "Brown Leather Handbag",
      ),
      ProfileItem(
        id: 's7',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Luxury Brand",
        itemName: "Gold Handbag",
      ),
      ProfileItem(
        id: 's8',
        imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Silk Collection",
        itemName: "Golden Silk Dress",
      ),
      ProfileItem(
        id: 's9',
        imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Italian Shoes",
        itemName: "Black High Heels",
      ),
      ProfileItem(
        id: 's10',
        imageUrl: 'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Classic Watch",
        itemName: "Luxury Watch",
      ),
      ProfileItem(
        id: 's11',
        imageUrl: 'https://images.unsplash.com/photo-1539185441755-769473a23570?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Zara",
        itemName: "Dark Red Heels",
      ),
      ProfileItem(
        id: 's12',
        imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=400&auto=format&fit=crop',
        price: 2450,
        likes: 2000,
        isSold: false,
        brand: "Designer Brand",
        itemName: "Brown Leather Handbag",
      ),
    ]);
  }
}
