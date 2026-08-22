import 'package:get/get.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        repository: Get.isRegistered<NotificationRepository>()
            ? Get.find<NotificationRepository>()
            : null,
      ),
    );
  }
}
