import 'package:get/get.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';

class MyPurchaseDitailsController extends GetxController {
  late final ProfileItem item;
  final rxOriginalPackaging = false.obs;
  final rxBillName = "Bill.pdf".obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ProfileItem) {
      item = Get.arguments as ProfileItem;
    } else {
      // Fallback
      item = ProfileItem(
        id: 'fallback_purchase',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=400&auto=format&fit=crop',
        price: 3200,
        likes: 2000,
        isSold: true,
        brand: "Chanel",
        itemName: "Classic Flap Bag",
        status: "Reserved",
      );
    }
  }
}
