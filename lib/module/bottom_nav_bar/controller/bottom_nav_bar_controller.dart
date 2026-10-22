import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';
import 'package:cpk1989/module/profile/controller/profile_controller.dart';
import 'package:cpk1989/data/repositories/user_repository.dart';

class BottomNavBarController extends GetxController
    with WidgetsBindingObserver {
  BottomNavBarController({NotificationRepository? repository, this.badgeWriter})
    : _repository = repository;
  final NotificationRepository? _repository;
  final Future<void> Function(int)? badgeWriter;
  final _selectedIndex = 0.obs;
  final rxUnreadNotificationCount = 0.obs;
  int _countEpoch = 0;
  Timer? _reconcileTimer;
  Future<void> _badgeQueue = Future.value();

  int get selectedIndex => _selectedIndex.value;
  int get unreadNotificationCount => rxUnreadNotificationCount.value;

  NotificationRepository? get _repo {
    if (_repository != null) return _repository;
    if (Get.isRegistered<NotificationRepository>()) {
      return Get.find<NotificationRepository>();
    }
    if (Get.isRegistered<ApiClient>()) {
      return NotificationRepository(apiClient: Get.find<ApiClient>());
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchUnreadCount();
    _reconcileTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        reconcileNotifications();
      }
    });
  }

  @override
  void onClose() {
    _reconcileTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) reconcileNotifications();
  }

  void reconcileNotifications() {
    fetchUnreadCount();
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications(
        isRefresh: true,
        silent: true,
      );
    }
  }

  void changeIndex(int index) {
    _selectedIndex.value = index;
    if (index == 2) reconcileNotifications();
    if (index == 3 &&
        Get.isRegistered<ProfileController>() &&
        Get.isRegistered<UserRepository>()) {
      Get.find<ProfileController>().fetchProfileStats();
    }
  }

  Future<void> fetchUnreadCount() async {
    final epoch = ++_countEpoch;
    try {
      final repo = _repo;
      if (repo == null) return;
      final response = await repo.getUnreadCount();
      if (epoch != _countEpoch || isClosed) return;
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data['data'];
        final value = raw is Map ? raw['unreadCount'] : raw;
        final count = int.tryParse('$value');
        if (count != null) updateUnreadCount(count);
      }
    } catch (e) {
      debugPrint('Error fetching unread notification count: $e');
    }
  }

  void updateUnreadCount(int count) {
    ++_countEpoch; // An older HTTP response must not overwrite a newer event.
    rxUnreadNotificationCount.value = count < 0 ? 0 : count;
    _badgeQueue = _badgeQueue.then((_) async {
      if (isClosed) return;
      try {
        if (badgeWriter != null) {
          await badgeWriter!(unreadNotificationCount);
        } else if (await AppBadgePlus.isSupported()) {
          await AppBadgePlus.updateBadge(unreadNotificationCount);
        }
        if (badgeWriter == null && unreadNotificationCount == 0) {
          await FlutterLocalNotificationsPlugin().cancelAll();
        }
      } catch (e) {
        debugPrint('Launcher badge sync failed: $e');
      }
    });
  }

  void decrementUnreadCount() => updateUnreadCount(unreadNotificationCount - 1);
  void clearUnreadCount() => updateUnreadCount(0);
}
