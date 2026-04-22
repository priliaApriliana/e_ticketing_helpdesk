import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  Map<String, int> stats = <String, int>{};
  Map<String, int> roleMetrics = <String, int>{};
  bool isLoading = false;

  void onInit() {
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = _authService.currentUser.value;
      final userId = user?.isUser == true ? user?.id : null;

      stats = _dashboardRepository.getStatistics(userId);
      final tickets = await _dashboardRepository.getTickets(userId: userId);

      if (user?.isUser == true) {
        roleMetrics = {
          'submitted': tickets.length,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'finish': tickets.where((t) => t.status == 'closed').length,
        };
      } else {
        final activeTickets = tickets.where((t) => t.status != 'closed').length;
        final unhandledTickets = tickets
            .where(
              (t) =>
                  t.status == 'open' &&
                  (t.assignedTo == null || t.assignedTo!.trim().isEmpty),
            )
            .length;
        roleMetrics = {
          'ticket_in': activeTickets,
          'ongoing': tickets.where((t) => t.status == 'in_progress').length,
          'unhandled': unhandledTickets,
          'approved_finish': tickets.where((t) => t.status == 'closed').length,
          'total_incoming': tickets.length,
        };
      }
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
