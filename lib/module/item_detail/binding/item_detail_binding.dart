import 'package:get/get.dart';
import 'package:cpk1989/module/item_detail/controller/item_detail_controller.dart';

class ItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemDetailController>(() => ItemDetailController());
  }
}
