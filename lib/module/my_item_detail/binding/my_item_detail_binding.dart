import 'package:get/get.dart';
import 'package:cpk1989/module/my_item_detail/controller/my_item_detail_controller.dart';

class MyItemDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyItemDetailController>(() => MyItemDetailController());
  }
}
