import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';

class BottomNavBarController extends GetxController {
  final _selectedIndex = 0.obs;
  final rxUnreadNotificationCount = 0.obs;

  int get selectedIndex => _selectedIndex.value;
  int get unreadNotificationCount => rxUnreadNotificationCount.value;

  NotificationRepository? get _repo {
    if (Get.isRegistered<NotificationRepository>()) {
      return Get.find<NotificationRepository>();
    } else if (Get.isRegistered<ApiClient>()) {
      return NotificationRepository(apiClient: Get.find<ApiClient>());
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  void changeIndex(int index) {
    _selectedIndex.value = index;
    if (index == 2) {
      fetchUnreadCount();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final repo = _repo;
      if (repo == null) return;

      final response = await repo.getUnreadCount();
      if (response.statusCode == 200 && response.data != null) {
        int unread = 0;
        final rawData = response.data['data'];
        if (rawData is Map) {
          unread = (rawData['unreadCount'] ?? 0) as int;
        } else if (rawData is int) {
          unread = rawData;
        }
        updateUnreadCount(unread);
      }
    } catch (e) {
      debugPrint('Error fetching unread notification count: $e');
    }
  }

  void updateUnreadCount(int count) {
    final safeCount = count < 0 ? 0 : count;
    rxUnreadNotificationCount.value = safeCount;
    _syncAppIconBadge(safeCount);
  }

  void decrementUnreadCount() {
    if (rxUnreadNotificationCount.value > 0) {
      final newCount = rxUnreadNotificationCount.value - 1;
      rxUnreadNotificationCount.value = newCount;
      _syncAppIconBadge(newCount);
    }
  }

  void clearUnreadCount() {
    rxUnreadNotificationCount.value = 0;
    _syncAppIconBadge(0);
  }

  Future<void> _syncAppIconBadge(int count) async {
    try {
      final isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (e) {
      debugPrint('AppBadgePlus error updating launcher badge: $e');
    }
  }
}
