import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/notification_service.dart';
import 'package:e_ticketing_helpdesk/features/notification/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();
  final _notificationService = Get.find<NotificationService>();

  List<NotificationModel> notifications = <NotificationModel>[];
  int unreadCount = 0;

  Worker? _authWorker;
  Worker? _notificationWorker;

  void onInit() {
    _authWorker = ever(_authService.currentUser, (_) => _refresh());
    _notificationWorker = ever<List<NotificationModel>>(
      _notificationService.notifications,
      (_) => _refresh(),
    );
    _refresh();
  }

  void _refresh() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) {
      notifications = <NotificationModel>[];
      unreadCount = 0;
      notifyListeners();
      return;
    }

    notifications = _notificationService.getByUser(userId);
    unreadCount = _notificationService.unreadCountByUser(userId);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;
    _notificationService.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }

  void markAllAsRead() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;
    _notificationService.markAllAsRead(userId);
  }

  void onClose() {
    _authWorker?.dispose();
    _notificationWorker?.dispose();
  }
}
