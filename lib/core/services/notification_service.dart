import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:e_ticketing_helpdesk/features/notification/data/models/notification_model.dart';
import 'package:e_ticketing_helpdesk/core/constants/api_constants.dart';

class NotificationService extends GetxService {
  final GetStorage _box = GetStorage();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_box.read('token')}',
      };

  @override
  void onInit() {
    super.onInit();
    if (_box.hasData('user')) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final userData = _box.read('user');
      if (userData == null) return;
      
      final userId = userData['id'];
      final response = await http.get(
        Uri.parse('${ApiConstants.notifications}?user_id=$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        notifications.value = data
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      // Handle error
    }
  }

  int getUnreadCount() {
    return notifications.where((item) => !item.isRead).length;
  }

  void addForUsers({
    required Set<String> recipientUserIds,
    required String title,
    required String message,
    String? ticketId,
    String? type,
    String? excludeUserId,
  }) async {
    for (final userId in recipientUserIds) {
      if (excludeUserId != null && userId == excludeUserId) continue;
      
      try {
        await http.post(
          Uri.parse(ApiConstants.notifications),
          headers: _headers,
          body: jsonEncode({
            'recipient_user_id': userId,
            'title': title,
            'message': message,
            'ticket_id': ticketId,
            'type': type,
          }),
        );
      } catch (e) {
        // Handle error
      }
    }
    fetchNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.markNotificationRead(notificationId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          notifications.refresh();
        }
      }
    } catch (e) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final userData = _box.read('user');
      if (userData == null) return;
      final userId = userData['id'];

      await http.put(
        Uri.parse('${ApiConstants.notifications}/read-all'),
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );
      fetchNotifications();
    } catch (e) {}
  }
}
