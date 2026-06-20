import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_list_widgets.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TicketProvider>();
    final authService = Get.find<AuthService>();
    
    return Obx(() {
      final user = authService.currentUser.value;
      
      // HAK AKSES: Hanya User dan Admin yang boleh buat tiket
      final bool canCreate = user?.role == 'user' || user?.role == 'admin';

      final tickets = ctrl.tickets;
      final total = tickets.length;
      final open = tickets.where((ticket) => ticket.status == 'open').length;
      final inProgress = tickets.where((ticket) => ticket.status == 'in_progress').length;
      final resolved = tickets.where((ticket) => ticket.status == 'resolved').length;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            const TicketListBackdrop(),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: ctrl.loadTickets,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  children: [
                    TicketListTopBar(onRefresh: ctrl.loadTickets),
                    const SizedBox(height: 18),
                    TicketHeroPanel(
                      userName: user?.name ?? 'Pengguna',
                      totalTickets: total,
                      openTickets: open,
                      inProgressTickets: inProgress,
                      resolvedTickets: resolved,
                    ),
                    const SizedBox(height: 16),
                    FilterPanel(controller: ctrl),
                    const SizedBox(height: 16),
                    TicketFeed(controller: ctrl),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Tombol hanya muncul jika diizinkan
        floatingActionButton: canCreate 
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.ticketCreate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Tiket'),
            )
          : null,
        bottomNavigationBar: const TicketListBottomNav(selectedIndex: 1),
      );
    });
  }
}
