import 'package:cpk1989/core/utils/resume_refresh_gate.dart';
import 'package:cpk1989/config/routes/app_pages.dart';
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
  final _resumeGate = ResumeRefreshGate();
  Future<void>? _unreadRequest;
  bool _unreadRefreshQueued = false;
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
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_resumeGate.shouldRefresh(
      state,
      checkoutActive: Get.currentRoute == AppRoutes.secureCheckout,
    )) {
      reconcileNotifications();
    }
  }

  void reconcileNotifications() {
    fetchUnreadCount();
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications(
        isRefresh: true,
        silent: true,
        refreshCount: false,
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

  Future<void> fetchUnreadCount({bool force = false}) {
    if (force && _unreadRequest != null) {
      ++_countEpoch;
      _unreadRefreshQueued = true;
    }
    return _unreadRequest ??= _fetchUnreadCount().whenComplete(() {
      _unreadRequest = null;
      if (_unreadRefreshQueued && !isClosed) {
        _unreadRefreshQueued = false;
        fetchUnreadCount();
      }
    });
  }

  Future<void> _fetchUnreadCount() async {
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
