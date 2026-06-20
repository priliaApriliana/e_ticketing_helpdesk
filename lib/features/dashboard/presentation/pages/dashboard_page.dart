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
    final authService = Get.find<AuthService>();
    
    return Obx(() {
      final user = authService.currentUser.value;
      final userName = user?.name ?? 'Pengguna';
      final roleName = formatRole(user?.role ?? '');
      
      // LOGIKA AKSES: Hanya User dan Admin yang boleh buat tiket
      final bool canCreate = user?.isUser == true || user?.isAdmin == true;

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
                  DashboardTopBar(userName: userName, role: roleName),
                  const SizedBox(height: 18),
                  HeroPanel(
                    greeting: dashCtrl.greeting,
                    userName: userName,
                    role: roleName,
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
                    canCreateTicket: canCreate, 
                    onTickets: () => Get.toNamed(Routes.ticketList),
                    onCreateTicket: canCreate ? () => Get.toNamed(Routes.ticketCreate) : null,
                    onProfile: () => Get.toNamed(Routes.profile),
                    onRefresh: () async {
                      final ticketProvider = context.read<TicketProvider>();
                      await dashCtrl.loadStats();
                      await ticketProvider.loadTickets();
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
        // FAB hanya untuk User & Admin
        floatingActionButton: canCreate 
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.ticketCreate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Tiket'),
            )
          : null, 
      );
    });
  }
}
