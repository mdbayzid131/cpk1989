import 'dart:async';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/data/repositories/notification_repository.dart';
import 'package:cpk1989/module/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:cpk1989/module/notification/controller/notification_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

Response reply(dynamic data, [int status = 200]) =>
    Response(requestOptions: RequestOptions(), statusCode: status, data: data);

class FakeNotifications extends NotificationRepository {
  FakeNotifications() : super(apiClient: ApiClient());
  int count = 3;
  int mutationStatus = 200;
  List<Map<String, dynamic>> items = [];
  final Map<int, List<Map<String, dynamic>>> pages = {};
  Future<Response> Function()? countRequest;
  Future<Response> Function()? listRequest;
  @override
  Future<Response> getUnreadCount() async => countRequest != null
      ? countRequest!()
      : reply({
          'data': {'unreadCount': count},
        });
  @override
  Future<Response> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unread,
  }) async => listRequest != null
      ? listRequest!()
      : reply({'data': pages[page] ?? items});
  @override
  Future<Response> markAsRead(String id) async => reply({}, mutationStatus);
  @override
  Future<Response> markAllAsRead() async => reply({}, mutationStatus);
  @override
  Future<Response> deleteNotification(String id) async =>
      reply({}, mutationStatus);
  @override
  Future<Response> deleteAllNotifications() async => reply({}, mutationStatus);
}

class QuietNavigation extends BottomNavBarController {
  QuietNavigation(FakeNotifications repo, {Future<void> Function(int)? writer})
    : super(repository: repo, badgeWriter: writer ?? ((_) async {}));
  @override
  // ignore: must_call_super
  void onInit() {}
}

class QuietNotifications extends NotificationController {
  QuietNotifications(FakeNotifications repo) : super(repository: repo);
  @override
  // ignore: must_call_super
  void onInit() {
    scrollController = ScrollController();
  }
}

Map<String, dynamic> push(String id) => {
  'notificationId': id,
  'title': 'Saved',
  'body': 'Saved to wishlist',
  'type': 'wishlist_item_saved',
  'unreadCount': '3',
  'createdAt': '2026-10-22T00:00:00Z',
};
NotificationItem item(String id) => NotificationItem(
  id: id,
  title: 'Saved',
  subtitle: '',
  timeAgo: '',
  dateGroup: 'TODAY',
  type: NotificationType.wishlistItemSaved,
);
Future<void> drain() async {
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());

  test(
    'push appears immediately and duplicate delivery never doubles count or list',
    () async {
      final repo = FakeNotifications();
      final pending = Completer<Response>();
      repo.listRequest = () => pending.future;
      final nav = Get.put<BottomNavBarController>(QuietNavigation(repo));
      final notifications = Get.put<NotificationController>(
        QuietNotifications(repo),
      );
      notifications.receivePush(push('n1'));
      expect(notifications.rxNotifications.single.id, 'n1');
      expect(nav.unreadNotificationCount, 3);
      notifications.receivePush(push('n1'));
      expect(notifications.rxNotifications.length, 1);
      expect(nav.unreadNotificationCount, 3);
      repo.listRequest = null;
      repo.items = [
        {'id': 'n1', 'title': 'Saved'},
      ];
      pending.complete(reply({'data': repo.items}));
      await drain();
    },
  );

  test(
    'stale unread HTTP response cannot overwrite a newer push count',
    () async {
      final repo = FakeNotifications();
      final pending = Completer<Response>();
      repo.countRequest = () => pending.future;
      final nav = Get.put<BottomNavBarController>(QuietNavigation(repo));
      final fetch = nav.fetchUnreadCount();
      nav.updateUnreadCount(5);
      pending.complete(
        reply({
          'data': {'unreadCount': 1},
        }),
      );
      await fetch;
      expect(nav.unreadNotificationCount, 5);
    },
  );

  test(
    'failed read and delete operations preserve unread notifications and badge',
    () async {
      final repo = FakeNotifications()..mutationStatus = 500;
      final nav = Get.put<BottomNavBarController>(QuietNavigation(repo));
      nav.updateUnreadCount(3);
      final notifications = Get.put<NotificationController>(
        QuietNotifications(repo),
      );
      notifications.rxNotifications.add(item('n1'));
      await notifications.markAsRead('n1');
      await notifications.markAllAsRead();
      expect(await notifications.deleteNotification('n1'), isFalse);
      await notifications.deleteAllNotifications();
      await drain();
      expect(notifications.rxNotifications.single.isRead, isFalse);
      expect(nav.unreadNotificationCount, 3);
    },
  );

  test('successful read and deletion reconcile exact server total', () async {
    final repo = FakeNotifications()..count = 2;
    final nav = Get.put<BottomNavBarController>(QuietNavigation(repo));
    nav.updateUnreadCount(3);
    final notifications = Get.put<NotificationController>(
      QuietNotifications(repo),
    );
    notifications.rxNotifications.add(item('n1'));
    await notifications.markAsRead('n1');
    await drain();
    expect(notifications.rxNotifications.single.isRead, isTrue);
    expect(nav.unreadNotificationCount, 2);
    repo.count = 0;
    expect(await notifications.deleteNotification('n1'), isTrue);
    await drain();
    expect(notifications.rxNotifications, isEmpty);
    expect(nav.unreadNotificationCount, 0);
  });

  test(
    'badge writes are serialized and finish at the latest unread total',
    () async {
      final repo = FakeNotifications();
      final blocked = Completer<void>();
      final written = <int>[];
      final nav = Get.put<BottomNavBarController>(
        QuietNavigation(
          repo,
          writer: (count) async {
            written.add(count);
            if (written.length == 1) await blocked.future;
          },
        ),
      );
      nav.updateUnreadCount(5);
      await drain();
      nav.updateUnreadCount(3);
      nav.clearUnreadCount();
      blocked.complete();
      await drain();
      expect(written.last, 0);
      expect(nav.unreadNotificationCount, 0);
    },
  );

  test(
    'a push during an old list fetch is not lost and pagination stays intact',
    () async {
      final repo = FakeNotifications();
      final pending = Completer<Response>();
      repo.listRequest = () => pending.future;
      final notifications = Get.put<NotificationController>(
        QuietNotifications(repo),
      );
      notifications.rxCurrentPage.value = 2;
      notifications.rxNotifications.add(item('old-page-2'));
      final fetching = notifications.fetchNotifications(silent: true);
      notifications.receivePush(push('n1'));
      repo.listRequest = null;
      repo.items = [
        {'id': 'n1', 'title': 'Saved'},
      ];
      repo.pages[2] = [
        {'id': 'old-page-2', 'title': 'Older'},
      ];
      pending.complete(reply({'data': []}));
      await fetching;
      await drain();
      expect(notifications.rxNotifications.map((n) => n.id), [
        'n1',
        'old-page-2',
      ]);
      expect(notifications.rxCurrentPage.value, 2);
    },
  );
}
