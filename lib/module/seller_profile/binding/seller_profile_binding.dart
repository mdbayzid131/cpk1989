import 'package:get/get.dart';
import 'package:cpk1989/module/seller_profile/controller/seller_profile_controller.dart';

class SellerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerProfileController>(() => SellerProfileController());
  }
}
