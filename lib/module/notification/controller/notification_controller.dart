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

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.dateGroup,
    required this.type,
    this.isRead = false,
    this.route,
  });
}

class NotificationController extends GetxController {
  final NotificationRepository? _repository;

  NotificationController({NotificationRepository? repository})
      : _repository = repository;

  final rxIsLoading = false.obs;
  final rxNotifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    rxIsLoading.value = true;
    try {
      if (_repository != null) {
        final response = await _repository.getNotifications();
        if (response.statusCode == 200 && response.data != null) {
          final List rawData = response.data['data'] ?? [];
          final fetched = rawData.map((json) {
            return NotificationItem(
              id: json['id'] ?? json['_id'] ?? '',
              title: json['title'] ?? 'Notification',
              subtitle: json['subtitle'] ?? json['body'] ?? '',
              timeAgo: _formatTime(json['createdAt']),
              dateGroup: _formatDateGroup(json['createdAt']),
              type: _parseType(json['type']),
              isRead: json['isRead'] ?? false,
            );
          }).toList();
          rxNotifications.assignAll(fetched);
          rxIsLoading.value = false;
          return;
        }
      }
    } catch (e) {
      debugPrint('Notification API error: $e');
    }

    rxIsLoading.value = false;
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
      );
    }).toList();

    rxNotifications.assignAll(updated);
    Get.snackbar(
      "Marked as Read",
      "All notifications have been marked as read.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E22),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteAllNotifications() async {
    try {
      if (_repository != null) {
        await _repository.deleteAllNotifications();
      }
    } catch (_) {}
    rxNotifications.clear();
    Get.snackbar(
      "Notifications Cleared",
      "All notifications have been deleted.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E22),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
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
