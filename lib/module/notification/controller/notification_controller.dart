import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';

enum NotificationType {
  // 1. Product & Seller
  itemListed,
  sellerOnboardingRequired,

  // 2. Order & Delivery Lifecycle
  orderSecured,
  itemReserved,
  collectionPending,
  itemCollected,
  collectionMissed,
  readyForDelivery,
  itemDelivered,
  orderCompleted,
  orderCancelled,
  deliveryCancelled,
  orderScheduleUpdated,

  // 3. Authentication & Verification
  itemVerification,
  authenticationPassed,
  authenticationFailed,

  // 4. Payment & Payout
  paymentFailed,
  paymentRefunded,
  payoutProcessing,
  payoutPaid,

  // 5. Wishlist
  wishlistItemSaved,
  wishlistItemUpdated,
  wishlistItemAvailable,
  wishlistItemUnavailable,

  // 6. Issues & Support
  issueCreated,
  issueResolved,

  // Fallback
  generic,
}

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String dateGroup;
  final NotificationType type;
  final bool isRead;
  final String? route;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.dateGroup,
    required this.type,
    this.isRead = false,
    this.route,
    this.data,
  });
}

class NotificationController extends GetxController {
  final NotificationRepository? _repository;

  NotificationController({NotificationRepository? repository})
    : _repository = repository;

  NotificationRepository? get _repo =>
      _repository ??
      (Get.isRegistered<NotificationRepository>()
          ? Get.find<NotificationRepository>()
          : null);

  final rxIsLoading = false.obs;
  final rxIsLoadingMore = false.obs;
  final rxHasMore = false.obs;
  final rxCurrentPage = 1.obs;
  final rxTotalPages = 1.obs;
  final rxNotifications = <NotificationItem>[].obs;

  int _version = 0;
  bool _fetching = false;
  bool _refreshQueued = false;
  final _pendingIds = <String>{};
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchNotifications();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      loadMoreNotifications();
    }
  }

  Future<void> fetchNotifications({
    bool isRefresh = false,
    bool silent = false,
    bool refreshCount = true,
  }) async {
    if (_fetching) {
      _refreshQueued = true;
      return;
    }
    _fetching = true;
    final version = _version;
    final preservePages = silent && rxCurrentPage.value > 1;
    final pagesToRefresh = preservePages ? rxCurrentPage.value : 1;
    if (isRefresh && !preservePages) {
      rxCurrentPage.value = 1;
      rxHasMore.value = false;
    }

    if (!silent) rxIsLoading.value = true;
    try {
      final repo = _repo;
      if (repo != null) {
        final responses = await Future.wait([
          for (var page = 1; page <= pagesToRefresh; page++)
            repo.getNotifications(page: page, limit: 20),
        ]);
        if (isClosed) return;
        if (responses.any((response) => response.statusCode != 200)) return;
        final response = responses.first;
        if (response.statusCode == 200 && response.data != null) {
          final List rawData = [
            for (final response in responses) ...response.data['data'] ?? [],
          ];
          final fetched = rawData.map((json) => _mapJsonToItem(json)).toList();

          if (version != _version) {
            _refreshQueued = true;
            return;
          }

          final pagination = response.data['pagination'];
          if (pagination != null) {
            final totalPage = (pagination['totalPage'] ?? 1) as int;
            rxTotalPages.value = totalPage;
            rxCurrentPage.value = pagesToRefresh > totalPage
                ? (totalPage < 1 ? 1 : totalPage)
                : pagesToRefresh;
            rxHasMore.value = rxCurrentPage.value < totalPage;
          } else if (!preservePages) {
            rxCurrentPage.value = 1;
            rxHasMore.value = fetched.length >= 20;
          }

          if (version == _version) {
            final seen = <String>{};
            rxNotifications.assignAll(
              fetched.where((item) => seen.add(item.id)),
            );
          } else {
            _refreshQueued = true;
          }
          if (refreshCount && Get.isRegistered<BottomNavBarController>()) {
            Get.find<BottomNavBarController>().fetchUnreadCount();
          }
        }
      }
    } catch (e) {
      debugPrint('Notification API error: $e');
    } finally {
      rxIsLoading.value = false;
      _fetching = false;
      if (_refreshQueued && !isClosed) {
        _refreshQueued = false;
        fetchNotifications(isRefresh: true, silent: true);
      }
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_fetching ||
        rxIsLoading.value ||
        rxIsLoadingMore.value ||
        !rxHasMore.value) {
      return;
    }

    rxIsLoadingMore.value = true;
    final version = _version;
    try {
      final repo = _repo;
      if (repo != null) {
        final nextPage = rxCurrentPage.value + 1;
        final response = await repo.getNotifications(page: nextPage, limit: 20);
        if (version != _version || isClosed) return;
        if (response.statusCode == 200 && response.data != null) {
          final List rawData = response.data['data'] ?? [];
          final fetched = rawData.map((json) => _mapJsonToItem(json)).toList();

          final pagination = response.data['pagination'];
          if (pagination != null) {
            final totalPage = (pagination['totalPage'] ?? 1) as int;
            rxTotalPages.value = totalPage;
            rxCurrentPage.value = nextPage;
            rxHasMore.value = nextPage < totalPage;
          } else {
            rxCurrentPage.value = nextPage;
            rxHasMore.value = fetched.isNotEmpty;
          }

          rxNotifications.addAll(
            fetched.where(
              (item) =>
                  !rxNotifications.any((existing) => existing.id == item.id),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Load more notifications error: $e');
    } finally {
      rxIsLoadingMore.value = false;
    }
  }

  NotificationItem _mapJsonToItem(dynamic json) {
    return NotificationItem(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? 'Notification',
      subtitle: json['subtitle'] ?? json['body'] ?? '',
      timeAgo: _formatTime(json['createdAt']),
      dateGroup: _formatDateGroup(json['createdAt']),
      type: _parseType(json['type']),
      isRead: json['isRead'] ?? false,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }

  void receivePush(Map<String, dynamic> payload) {
    final count = int.tryParse('${payload['unreadCount']}');
    final id = (payload['notificationId'] ?? payload['id'])?.toString();
    final alreadyPresent =
        id != null && rxNotifications.any((item) => item.id == id);
    if (id != null &&
        id.isNotEmpty &&
        !alreadyPresent &&
        payload['title'] != null) {
      ++_version;
      rxNotifications.insert(
        0,
        _mapJsonToItem({
          'id': id,
          'title': payload['title'],
          'body': payload['body'],
          'type': payload['type'],
          'createdAt': payload['createdAt'],
          'data': payload,
          'isRead': false,
        }),
      );
    }
    if (Get.isRegistered<BottomNavBarController>()) {
      final nav = Get.find<BottomNavBarController>();
      if (count != null && !alreadyPresent) nav.updateUnreadCount(count);
      if (count == null) nav.fetchUnreadCount();
    }
    if (payload['type'] == 'notification_sync' ||
        id == null ||
        payload['title'] == null) {
      fetchNotifications(
        isRefresh: true,
        silent: true,
        refreshCount: count == null,
      );
    }
  }

  NotificationItem _readItem(NotificationItem item) => NotificationItem(
    id: item.id,
    title: item.title,
    subtitle: item.subtitle,
    timeAgo: item.timeAgo,
    dateGroup: item.dateGroup,
    type: item.type,
    isRead: true,
    route: item.route,
    data: item.data,
  );

  bool _success(dynamic response) =>
      response.statusCode != null &&
      response.statusCode >= 200 &&
      response.statusCode < 300;

  void _reconcileCount() {
    if (Get.isRegistered<BottomNavBarController>()) {
      Get.find<BottomNavBarController>().fetchUnreadCount(force: true);
    }
  }

  Future<void> markAsRead(String id) async {
    if (_pendingIds.contains(id)) return;
    final item = rxNotifications.firstWhereOrNull((item) => item.id == id);
    if (item == null || item.isRead || _repo == null) return;
    _pendingIds.add(id);
    try {
      if (!_success(await _repo!.markAsRead(id))) return;
      ++_version;
      final index = rxNotifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        rxNotifications[index] = _readItem(rxNotifications[index]);
      }
    } catch (e) {
      debugPrint('Mark notification read failed: $e');
    } finally {
      _pendingIds.remove(id);
      _reconcileCount();
    }
  }

  Future<void> markAllAsRead() async {
    if (_repo == null) return;
    final ids = rxNotifications.map((item) => item.id).toSet();
    try {
      if (!_success(await _repo!.markAllAsRead())) return;
      ++_version;
      rxNotifications.assignAll(
        rxNotifications
            .map((item) => ids.contains(item.id) ? _readItem(item) : item)
            .toList(),
      );
      await fetchNotifications(isRefresh: true, silent: true);
    } catch (e) {
      debugPrint('Mark all read failed: $e');
    } finally {
      _reconcileCount();
    }
  }

  Future<bool> deleteNotification(String id) async {
    if (_repo == null || _pendingIds.contains(id)) return false;
    _pendingIds.add(id);
    try {
      if (!_success(await _repo!.deleteNotification(id))) return false;
      ++_version;
      rxNotifications.removeWhere((item) => item.id == id);
      return true;
    } catch (e) {
      debugPrint('Delete notification failed: $e');
      return false;
    } finally {
      _pendingIds.remove(id);
      _reconcileCount();
    }
  }

  Future<void> deleteAllNotifications() async {
    if (_repo == null) return;
    final ids = rxNotifications.map((item) => item.id).toSet();
    try {
      if (!_success(await _repo!.deleteAllNotifications())) return;
      ++_version;
      rxNotifications.removeWhere((item) => ids.contains(item.id));
      await fetchNotifications(isRefresh: true, silent: true);
    } catch (e) {
      debugPrint('Delete all notifications failed: $e');
    } finally {
      _reconcileCount();
    }
  }

  NotificationType _parseType(String? typeStr) {
    final cleaned = typeStr?.toLowerCase().replaceAll('_', '') ?? '';
    switch (cleaned) {
      // 1. Product & Seller
      case 'itemlisted':
        return NotificationType.itemListed;
      case 'selleronboardingrequired':
      case 'sellerdetails':
        return NotificationType.sellerOnboardingRequired;

      // 2. Order & Delivery Lifecycle
      case 'ordersecured':
        return NotificationType.orderSecured;
      case 'itemreserved':
        return NotificationType.itemReserved;
      case 'collectionpending':
        return NotificationType.collectionPending;
      case 'itemcollected':
        return NotificationType.itemCollected;
      case 'collectionmissed':
        return NotificationType.collectionMissed;
      case 'readyfordelivery':
        return NotificationType.readyForDelivery;
      case 'itemdelivered':
        return NotificationType.itemDelivered;
      case 'ordercompleted':
        return NotificationType.orderCompleted;
      case 'ordercancelled':
        return NotificationType.orderCancelled;
      case 'deliverycancelled':
        return NotificationType.deliveryCancelled;
      case 'orderscheduleupdated':
        return NotificationType.orderScheduleUpdated;

      // 3. Authentication & Verification
      case 'itemverification':
        return NotificationType.itemVerification;
      case 'authenticationpassed':
      case 'itemauthenticated':
        return NotificationType.authenticationPassed;
      case 'authenticationfailed':
        return NotificationType.authenticationFailed;

      // 4. Payment & Payout
      case 'paymentfailed':
        return NotificationType.paymentFailed;
      case 'paymentrefunded':
        return NotificationType.paymentRefunded;
      case 'payoutprocessing':
        return NotificationType.payoutProcessing;
      case 'payoutpaid':
        return NotificationType.payoutPaid;

      // 5. Wishlist
      case 'wishlistitemsaved':
      case 'itemsaved':
        return NotificationType.wishlistItemSaved;
      case 'wishlistitemupdated':
        return NotificationType.wishlistItemUpdated;
      case 'wishlistitemavailable':
        return NotificationType.wishlistItemAvailable;
      case 'wishlistitemunavailable':
        return NotificationType.wishlistItemUnavailable;

      // 6. Issues & Support
      case 'issuecreated':
        return NotificationType.issueCreated;
      case 'issueresolved':
        return NotificationType.issueResolved;

      default:
        return NotificationType.generic;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
      }
    } catch (_) {
      return 'Just now';
    }
  }

  String _formatDateGroup(String? dateStr) {
    if (dateStr == null) return 'TODAY';
    try {
      final dateTime = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'TODAY';
      }
      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    } catch (_) {
      return 'TODAY';
    }
  }

  Map<String, List<NotificationItem>> get groupedNotifications {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in rxNotifications) {
      grouped.putIfAbsent(item.dateGroup, () => []).add(item);
    }
    return grouped;
  }
}
