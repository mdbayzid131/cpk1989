import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  /// Get Notifications: GET /notifications
  Future<Response> getNotifications({int page = 1, int limit = 20}) async {
    return await apiClient.getData(
      ApiConstants.notifications,
      query: {'page': page, 'limit': limit},
    );
  }

  /// Mark single notification as read: PATCH /notifications/:id/read
  Future<Response> markAsRead(String id) async {
    return await apiClient.patchData('${ApiConstants.notifications}/$id/read', {});
  }

  /// Mark all notifications as read: PATCH /notifications/read-all
  Future<Response> markAllAsRead() async {
    return await apiClient.patchData('${ApiConstants.notifications}/read-all', {});
  }
}
