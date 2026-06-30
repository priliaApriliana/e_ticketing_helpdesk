import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/socket_service.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final _socketService = Get.find<SocketService>();

  final stats = <String, int>{}.obs;
  final roleMetrics = <String, int>{}.obs;
  final isLoading = false.obs;

  Worker? _authWorker;

  void onInit() {
    _authWorker = ever(_authService.currentUser, (user) {
      if (user != null) loadStats();
    });
    
    loadStats();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _socketService.on('stats_updated', (_) => loadStats());
    
    _socketService.on('ticket_created', (data) {
      loadStats();
      _showTopSnackbar(
        title: 'Tiket Baru Masuk!',
        message: data?['title'] ?? 'Seorang pengguna baru saja mengirim tiket.',
        icon: Icons.confirmation_num_rounded,
        color: const Color(0xFF4F46E5),
      );
    });

    _socketService.on('ticket_updated', (_) => loadStats());
    _socketService.on('ticket_status_updated', (_) => loadStats());
    
    _socketService.on('new_notification', (data) {
      loadStats();
      _showTopSnackbar(
        title: 'Notifikasi Baru',
        message: data?['message'] ?? 'Anda memiliki pesan sistem baru.',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFDC2626),
      );
    });
  }

  void _showTopSnackbar({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      boxShadows: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Future<void> loadStats() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    notifyListeners();
    try {
      // 1. Ambil Statistik Ringkasan (Admin/Helpdesk ambil global, User/Teknisi ambil personal)
      final summary = await _dashboardRepository.getStatistics(
        userId: (user.isAdmin || user.isHelpdesk) ? null : user.id,
      );
      stats.assignAll(summary);

      // 2. Ambil Daftar Tiket untuk kalkulasi metrik detail
      final tickets = await _dashboardRepository.getTickets(
        userId: (user.isAdmin || user.isHelpdesk) ? null : user.id,
      );

      // 3. Kalkulasi metrik sesuai role
      Map<String, int> calculated = {};
      if (user.isUser) {
        calculated = {
          'submitted': summary['total'] ?? 0,
          'ongoing': summary['in_progress'] ?? 0,
          'finish': (summary['resolved'] ?? 0) + (summary['closed'] ?? 0),
        };
      } else if (user.isTechnicalSupport && !user.isAdmin) {
        calculated = {
          'my_tasks': tickets.length,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'resolved': tickets.where((t) => t.status == 'resolved').length,
        };
      } else {
        // Logika untuk Admin / Helpdesk
        final unhandled = tickets.where((t) => t.status == 'open' && t.assignedTo == null).length;
        calculated = {
          'ticket_in': summary['open'] ?? 0,
          'unhandled': unhandled,
          'ongoing': summary['in_progress'] ?? 0,
          'approved_finish': (summary['resolved'] ?? 0) + (summary['closed'] ?? 0),
          'total_incoming': summary['total'] ?? 0,
        };
      }
      
      roleMetrics.assignAll(calculated);

    } catch (e) {
      debugPrint('Dashboard Error: $e');
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }
}
