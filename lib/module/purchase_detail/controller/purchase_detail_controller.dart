import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class PurchaseDetailController extends GetxController {
  late final ProfileItem item;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback',
        imageUrl: '',
        price: 0,
        likes: 0,
        isSold: true,
        brand: "",
        itemName: "",
        status: null,
      );
    }
  }
}
