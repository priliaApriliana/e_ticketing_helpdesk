import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/notification_service.dart';
import 'package:e_ticketing_helpdesk/features/notification/data/models/notification_model.dart';

class NotificationProvider extends GetxController {
  final _authService = Get.find<AuthService>();
  final _notificationService = Get.find<NotificationService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  Worker? _authWorker;
  Worker? _notificationWorker;

  @override
  void onInit() {
    super.onInit();
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
      notifications.clear();
      unreadCount.value = 0;
      return;
    }

    notifications.value = _notificationService.getByUser(userId);
    unreadCount.value = _notificationService.unreadCountByUser(userId);
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

  @override
  void onClose() {
    _authWorker?.dispose();
    _notificationWorker?.dispose();
    super.onClose();
  }
}
