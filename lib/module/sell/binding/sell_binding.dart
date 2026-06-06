import 'package:get/get.dart';
import 'package:cpk1989/module/sell/controller/sell_controller.dart';

class SellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellController>(() => SellController());
  }
}
