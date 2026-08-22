import 'package:get/get.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/home/controller/home_controller.dart';
import 'package:cpk1989/module/wishlist/controller/wishlist_controller.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class BottomNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BottomNavBarController>(BottomNavBarController());
    Get.put<HomeController>(HomeController());
    Get.put<WishlistController>(WishlistController());
    if (Get.isRegistered<ApiClient>()) {
      Get.lazyPut<NotificationRepository>(
        () => NotificationRepository(apiClient: Get.find<ApiClient>()),
      );
    }
    Get.put<NotificationController>(
      NotificationController(
        repository: Get.isRegistered<NotificationRepository>()
            ? Get.find<NotificationRepository>()
            : null,
      ),
    );
    Get.put<ProfileController>(ProfileController());
  }
}
