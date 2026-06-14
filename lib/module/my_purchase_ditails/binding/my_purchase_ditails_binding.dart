import 'package:get/get.dart';
import 'package:cpk1989/module/my_purchase_ditails/controller/my_purchase_ditails_controller.dart';

class MyPurchaseDitailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPurchaseDitailsController>(() => MyPurchaseDitailsController());
  }
}
