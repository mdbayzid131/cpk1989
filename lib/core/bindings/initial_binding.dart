import 'package:get/get.dart';
import 'package:cpk1989/core/controllers/internet_controller.dart';
import 'package:cpk1989/core/services/connectivity_service.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/core/services/auth_service.dart';
import 'package:cpk1989/core/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);

    // Global controllers
    Get.put(InternetController(), permanent: true);

    // Services init
    ConnectivityService.init();
  }
}
