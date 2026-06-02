import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class NotificationRepository {
  final ApiClient apiClient = Get.find<ApiClient>();

  Future<Response> getNotifications({String? cursor}) async {
    return await apiClient.getData(
      ApiConstants.notifications,
      query: cursor != null ? {'cursor': cursor} : null,
    );
  }

  Future<Response> markAsRead(String notificationId) async {
    return await apiClient.patchData(
      ApiConstants.readNotification.replaceAll('{id}', notificationId),
      {},
    );
  }

  Future<Response> markAllAsRead() async {
    return await apiClient.patchData(
      ApiConstants.readAllNotifications,
      {},
    );
  }

  Future<Response> deleteNotification(String notificationId) async {
    return await apiClient.deleteData(
      ApiConstants.deleteNotification.replaceAll('{id}', notificationId),
    );
  }
}
