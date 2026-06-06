import 'package:get/get.dart';
import 'package:cpk1989/module/purchase_detail/controller/purchase_detail_controller.dart';

class PurchaseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseDetailController>(() => PurchaseDetailController());
  }
}
