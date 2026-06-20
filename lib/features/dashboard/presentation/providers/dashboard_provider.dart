import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/socket_service.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final _socketService = Get.find<SocketService>();

  Map<String, int> stats = <String, int>{};
  Map<String, int> roleMetrics = <String, int>{};
  bool isLoading = false;

  void onInit() {
    loadStats();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _socketService.on('stats_updated', (_) => loadStats());
    _socketService.on('ticket_created', (_) => loadStats());
    _socketService.on('ticket_updated', (_) => loadStats());
  }

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = _authService.currentUser.value;
      if (user == null) return;
      
      String? createdBy;
      String? assignedTo;

      if (user.isUser) {
        createdBy = user.id;
      } else if (user.isTechnicalSupport && !user.isAdmin) {
        assignedTo = user.id;
      }

      // 1. Ambil Statistik Ringkasan (Hero Panel & Chart)
      // Kita asumsikan API dashboard/metrics sudah support created_by/assigned_to
      stats = await _dashboardRepository.getStatistics(
        createdBy: createdBy,
        assignedTo: assignedTo,
      );

      // 2. Ambil Daftar Tiket untuk menghitung Role Metrics secara detail
      final tickets = await _dashboardRepository.getTickets(
        createdBy: createdBy,
        assignedTo: assignedTo,
      );

      if (user.isUser) {
        roleMetrics = {
          'submitted': tickets.length,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'finish': tickets.where((t) => t.status == 'resolved' || t.status == 'closed').length,
        };
      } else if (user.isTechnicalSupport && !user.isAdmin) {
        roleMetrics = {
          'my_tasks': tickets.length,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'resolved': tickets.where((t) => t.status == 'resolved').length,
        };
      } else {
        // Dashboard Helpdesk / Admin: Global
        final unhandled = tickets.where((t) => t.status == 'open' && (t.assignedTo == null)).length;
        roleMetrics = {
          'ticket_in': tickets.where((t) => t.status != 'closed' && t.status != 'resolved').length,
          'unhandled': unhandled,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'total_incoming': tickets.length,
        };
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
    } finally {
      isLoading = false;
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
}
