import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/notification_service.dart';
import 'package:e_ticketing_helpdesk/core/services/socket_service.dart';
import 'package:e_ticketing_helpdesk/features/notification/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();
  final _notificationService = Get.find<NotificationService>();
  final _socketService = Get.find<SocketService>();

  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;

  Worker? _authWorker;

  void onInit() {
    _authWorker = ever(_authService.currentUser, (_) => refresh());

    // MENDENGARKAN REAL-TIME NOTIFIKASI
    _socketService.on('new_notification', (data) {
      print('>>> Sinyal Notifikasi Baru Diterima: $data');
      
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return;

      // Logika penentuan apakah notifikasi ini untuk user yang sedang login
      bool isForMe = false;
      if (data != null && data is Map) {
        if (data['type'] == 'new_ticket') {
          // Tiket baru biasanya untuk Admin & Helpdesk
          isForMe = currentUser.role == 'admin' || currentUser.role == 'helpdesk';
        } else if (data['recipient_id'] != null) {
          // Jika ada recipient_id spesifik
          isForMe = data['recipient_id'].toString() == currentUser.id.toString();
        } else {
          // Fallback jika tidak ada info spesifik, coba refresh saja
          isForMe = true;
        }
      } else {
        isForMe = true;
      }

      if (isForMe) {
        // Beri sedikit delay agar transaksi DB di backend selesai sepenuhnya
        Future.delayed(const Duration(milliseconds: 500), () => refresh());
        _showNotificationSnackbar(data);
      }
    });

    refresh();
  }

  void _showNotificationSnackbar(dynamic data) {
    String title = "Pemberitahuan";
    String message = "Ada aktivitas baru pada sistem helpdesk.";
    IconData icon = Icons.notifications_active;

    if (data != null && data is Map) {
      final type = data['type'];
      if (type == 'new_ticket') {
        title = "Tiket Baru Masuk 🎫";
        message = "Seorang user baru saja mengirimkan laporan bantuan baru.";
      } else if (type == 'status_update') {
        title = "Update Status Tiket";
        message = "Status tiket telah diperbarui.";
        icon = Icons.update;
      } else if (type == 'ticket_assigned') {
        title = "Tugas Tiket Baru 🛠️";
        message = "Anda telah ditugaskan untuk menangani tiket baru.";
        icon = Icons.assignment_ind;
      }
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.indigo.withOpacity(0.95),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  Future<void> refresh() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      notifications = [];
      unreadCount = 0;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _notificationService.fetchNotifications();
      notifications = _notificationService.notifications;
      unreadCount = _notificationService.getUnreadCount();
      print('>>> Notifikasi diperbarui. Total: ${notifications.length}, Belum dibaca: $unreadCount');
    } catch (e) {
      print('>>> Gagal refresh notifikasi: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    refresh();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    refresh();
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }
}
