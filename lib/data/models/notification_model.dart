class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String subtitle;
  final String resourceType;
  final String resourceId;
  final NotificationLink? link;
  final bool isRead;
  final DateTime? readAt;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.resourceType,
    required this.resourceId,
    this.link,
    required this.isRead,
    this.readAt,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      resourceType: json['resourceType'] ?? '',
      resourceId: json['resourceId'] ?? '',
      link: json['link'] != null ? NotificationLink.fromJson(json['link']) : null,
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class NotificationLink {
  final String label;
  final String url;

  NotificationLink({required this.label, required this.url});

  factory NotificationLink.fromJson(Map<String, dynamic> json) {
    return NotificationLink(
      label: json['label'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> data;
  final NotificationMeta meta;

  NotificationResponse({required this.data, required this.meta});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      meta: NotificationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class NotificationMeta {
  final int limit;
  final String? nextCursor;
  final bool hasMore;
  final int unreadCount;

  NotificationMeta({
    required this.limit,
    this.nextCursor,
    required this.hasMore,
    required this.unreadCount,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      limit: json['limit'] ?? 20,
      nextCursor: json['nextCursor'],
      hasMore: json['hasMore'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
