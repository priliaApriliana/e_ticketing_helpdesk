import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = context.watch<DashboardProvider>();
    final authService = context.read<AuthService>();
    final user = authService.currentUser.value;
    final userName = user?.name ?? 'Pengguna';
    final role = formatRole(user?.role ?? '');
    final stats = dashCtrl.stats;
    final total = stats['total'] ?? 0;
    final open = stats['open'] ?? 0;
    final inProgress = stats['in_progress'] ?? 0;
    final resolved = stats['resolved'] ?? 0;
    final closed = stats['closed'] ?? 0;
    final roleMetrics = dashCtrl.roleMetrics;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const DashboardBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                DashboardTopBar(userName: userName, role: role),
                const SizedBox(height: 18),
                HeroPanel(
                  greeting: dashCtrl.greeting,
                  userName: userName,
                  role: role,
                  totalTickets: total,
                  openTickets: open,
                ),
                const SizedBox(height: 16),
                RoleMetricsPanel(
                  isUser: user?.isUser == true,
                  metrics: roleMetrics,
                ),
                const SizedBox(height: 16),
                SnapshotPanel(
                  total: total,
                  open: open,
                  inProgress: inProgress,
                  resolved: resolved,
                  closed: closed,
                ),
                const SizedBox(height: 16),
                QuickActionsPanel(
                  canCreateTicket: true, // Revisi: Diaktifkan untuk semua role
                  onTickets: () => Get.toNamed(Routes.ticketList),
                  onCreateTicket: () => Get.toNamed(Routes.ticketCreate), // Revisi: Diaktifkan untuk semua role
                  onProfile: () => Get.toNamed(Routes.profile),
                  onRefresh: () async {
                    final ticketProvider = context.read<TicketProvider>();
                    final scheme = Theme.of(context).colorScheme;
                    await dashCtrl.loadStats();
                    await ticketProvider.loadTickets();
                    Get.snackbar(
                      'Diperbarui',
                      'Statistik dan daftar tiket sudah disegarkan',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: scheme.inverseSurface,
                      colorText: scheme.onInverseSurface,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const RecentTicketsPanel(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ticketCreate),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Tiket'),
      ), // Revisi: Diaktifkan untuk semua role
    );
  }
}
