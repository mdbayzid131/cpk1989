import 'package:get/get.dart';
import 'package:cpk1989/module/sell_item_detail/controller/sell_item_detail_controller.dart';

class SellItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellItemDetailController>(() => SellItemDetailController());
  }
}
