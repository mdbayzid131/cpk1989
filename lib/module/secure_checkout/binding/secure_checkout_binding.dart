import 'package:get/get.dart';
import 'package:cpk1989/module/secure_checkout/controller/secure_checkout_controller.dart';

class SecureCheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecureCheckoutController>(() => SecureCheckoutController());
  }
}
