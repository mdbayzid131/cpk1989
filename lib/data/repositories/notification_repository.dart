import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  /// Get Notifications: GET /notifications
  Future<Response> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unread,
  }) async {
    final Map<String, dynamic> query = {'page': page, 'limit': limit};
    if (unread != null) {
      query['unread'] = unread;
    }
    return await apiClient.getData(
      ApiConstants.notifications,
      query: query,
    );
  }

  /// Get Unread Badge Count: GET /notifications/unread-count
  Future<Response> getUnreadCount() async {
    return await apiClient.getData('${ApiConstants.notifications}/unread-count');
  }

  /// Mark single notification as read: PATCH /notifications/:id/read
  Future<Response> markAsRead(String id) async {
    return await apiClient.patchData('${ApiConstants.notifications}/$id/read', {});
  }

  /// Mark all notifications as read: PATCH /notifications/read-all
  Future<Response> markAllAsRead() async {
    return await apiClient.patchData('${ApiConstants.notifications}/read-all', {});
  }

  /// Delete single notification: DELETE /notifications/:id
  Future<Response> deleteNotification(String id) async {
    return await apiClient.deleteData('${ApiConstants.notifications}/$id');
  }

  /// Delete all notifications: DELETE /notifications/all
  Future<Response> deleteAllNotifications() async {
    return await apiClient.deleteData('${ApiConstants.notifications}/all');
  }

  /// Register or refresh device FCM token: POST /notifications/devices
  Future<Response> registerDevice({
    required String registrationToken,
    required String platform,
    required String deviceId,
  }) async {
    return await apiClient.postData('${ApiConstants.notifications}/devices', {
      'registrationToken': registrationToken,
      'platform': platform,
      'deviceId': deviceId,
    });
  }

  /// Unregister device FCM token before logout: DELETE /notifications/devices
  Future<Response> unregisterDevice({
    required String registrationToken,
  }) async {
    return await apiClient.deleteData(
      '${ApiConstants.notifications}/devices',
      body: {'registrationToken': registrationToken},
    );
  }
}
