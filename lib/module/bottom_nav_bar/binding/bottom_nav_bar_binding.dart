import 'package:get/get.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/wishlist/controller/wishlist_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class BottomNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WishlistController>(() => WishlistController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
