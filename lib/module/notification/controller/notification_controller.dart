import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';

enum NotificationType {
  orderSecured,
  itemCollected,
  itemAuthenticated,
  itemReserved,
  sellerDetails,
  itemSaved,
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

  final rxIsLoading = false.obs;
  final rxIsLoadingMore = false.obs;
  final rxHasMore = false.obs;
  final rxCurrentPage = 1.obs;
  final rxTotalPages = 1.obs;
  final rxNotifications = <NotificationItem>[].obs;

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

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      rxCurrentPage.value = 1;
      rxHasMore.value = false;
    }

    rxIsLoading.value = true;
    try {
      if (_repository != null) {
        final response = await _repository.getNotifications(
          page: 1,
          limit: 20,
        );
        if (response.statusCode == 200 && response.data != null) {
          final List rawData = response.data['data'] ?? [];
          final fetched = rawData.map((json) => _mapJsonToItem(json)).toList();

          final pagination = response.data['pagination'];
          if (pagination != null) {
            final totalPage = (pagination['totalPage'] ?? 1) as int;
            rxTotalPages.value = totalPage;
            rxCurrentPage.value = 1;
            rxHasMore.value = 1 < totalPage;
          } else {
            rxCurrentPage.value = 1;
            rxHasMore.value = fetched.length >= 20;
          }

          rxNotifications.assignAll(fetched);
        }
      }
    } catch (e) {
      debugPrint('Notification API error: $e');
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (rxIsLoading.value || rxIsLoadingMore.value || !rxHasMore.value) return;

    rxIsLoadingMore.value = true;
    try {
      if (_repository != null) {
        final nextPage = rxCurrentPage.value + 1;
        final response = await _repository.getNotifications(
          page: nextPage,
          limit: 20,
        );
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

          rxNotifications.addAll(fetched);
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

  Future<void> markAllAsRead() async {
    try {
      if (_repository != null) {
        await _repository.markAllAsRead();
      }
    } catch (_) {}

    final updated = rxNotifications.map((item) {
      return NotificationItem(
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
    }).toList();

    rxNotifications.assignAll(updated);
  }

  Future<void> deleteAllNotifications() async {
    try {
      if (_repository != null) {
        await _repository.deleteAllNotifications();
      }
    } catch (_) {}
    rxNotifications.clear();
  }

  NotificationType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'order_secured':
      case 'ordersecured':
        return NotificationType.orderSecured;
      case 'item_collected':
      case 'itemcollected':
        return NotificationType.itemCollected;
      case 'item_authenticated':
      case 'item_verification':
      case 'itemauthenticated':
        return NotificationType.itemAuthenticated;
      case 'item_reserved':
      case 'itemreserved':
        return NotificationType.itemReserved;
      case 'seller_details':
      case 'sellerdetails':
        return NotificationType.sellerDetails;
      case 'item_saved':
      case 'itemsaved':
        return NotificationType.itemSaved;
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
        'DEC'
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
