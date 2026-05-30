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
  bool isLoading = false;

  Worker? _authWorker;
  Worker? _notificationWorker;

  void onInit() {
    _authWorker = ever(_authService.currentUser, (_) => refresh());
    _notificationWorker = ever<List<NotificationModel>>(
      _notificationService.notifications,
      (newList) {
        notifications = newList;
        unreadCount = _notificationService.getUnreadCount();
        notifyListeners();
      },
    );
    refresh();
  }

  Future<void> refresh() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      notifications = <NotificationModel>[];
      unreadCount = 0;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    
    await _notificationService.fetchNotifications();
    
    notifications = _notificationService.notifications;
    unreadCount = _notificationService.getUnreadCount();
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    // Refresh otomatis via worker notification
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    // Refresh otomatis via worker notification
  }

  void onClose() {
    _authWorker?.dispose();
    _notificationWorker?.dispose();
  }
}
