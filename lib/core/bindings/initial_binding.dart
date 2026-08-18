import 'package:get/get.dart';
import 'package:cpk1989/core/controllers/internet_controller.dart';
import 'package:cpk1989/core/services/connectivity_service.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';
import 'package:cpk1989/data/repositories/product_repository.dart';
import 'package:cpk1989/data/repositories/user_repository.dart';
import 'package:cpk1989/data/repositories/payment_repository.dart';
import 'package:cpk1989/core/services/payment_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(PaymentService(), permanent: true);

    // Repositories
    Get.lazyPut(
      () => ProductRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => UserRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => PaymentRepository(), fenix: true);

    // Global controllers
    Get.put(InternetController(), permanent: true);

    // Services init
    ConnectivityService.init();
  }
}
