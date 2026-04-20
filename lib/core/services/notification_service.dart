import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:e_ticketing_helpdesk/features/notification/data/models/notification_model.dart';

class NotificationService extends GetxService {
  final GetStorage _box = GetStorage();
  static const String _notificationsKey = 'notifications_data';

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final stored = _box.read(_notificationsKey);
    if (stored is List) {
      notifications
        ..clear()
        ..addAll(
          stored
              .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
        );
    }
  }

  void _save() {
    _box.write(
      _notificationsKey,
      notifications.map((item) => item.toJson()).toList(),
    );
  }

  List<NotificationModel> getByUser(String userId) {
    final items = notifications.where((item) => item.recipientUserId == userId).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  int unreadCountByUser(String userId) {
    return notifications.where((item) => item.recipientUserId == userId && !item.isRead).length;
  }

  void addForUsers({
    required Set<String> recipientUserIds,
    required String title,
    required String message,
    String? ticketId,
    String? type,
    String? excludeUserId,
  }) {
    if (recipientUserIds.isEmpty) return;

    for (final userId in recipientUserIds) {
      if (userId.isEmpty) continue;
      if (excludeUserId != null && userId == excludeUserId) continue;

      notifications.add(
        NotificationModel(
          id: 'N-${DateTime.now().millisecondsSinceEpoch}-$userId',
          recipientUserId: userId,
          title: title,
          message: message,
          createdAt: DateTime.now(),
          ticketId: ticketId,
          type: type,
        ),
      );
    }

    _save();
  }

  void markAsRead({required String userId, required String notificationId}) {
    final index = notifications.indexWhere(
      (item) => item.id == notificationId && item.recipientUserId == userId,
    );
    if (index == -1) return;

    notifications[index] = notifications[index].copyWith(isRead: true);
    notifications.refresh();
    _save();
  }

  void markAllAsRead(String userId) {
    var changed = false;
    for (var i = 0; i < notifications.length; i++) {
      final item = notifications[i];
      if (item.recipientUserId == userId && !item.isRead) {
        notifications[i] = item.copyWith(isRead: true);
        changed = true;
      }
    }

    if (changed) {
      notifications.refresh();
      _save();
    }
  }
}
