import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_detail_widgets.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<TicketProvider>();
    final authService = context.read<AuthService>();
    final String ticketId = Get.arguments as String;

    // Load data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadTicketDetail(ticketId);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const DetailBackdrop(),
          SafeArea(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final ticket = ctrl.selectedTicket.value;
              if (ticket == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Tiket tidak ditemukan'),
                      TextButton(
                        onPressed: () => ctrl.loadTicketDetail(ticketId),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              final statusColor = AppTheme.statusColor(ticket.status);
              final priorityColor = AppTheme.priorityColor(ticket.priority);
              
              final user = authService.currentUser.value;
              final bool isStaff = user?.isStaff == true;

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ctrl.loadTicketDetail(ticketId),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                        children: [
                          DetailTopBar(
                            onMenu: () {
                              if (!isStaff) return;
                              showActionMenu(
                                context,
                                ctrl,
                                ticketId,
                                authService,
                              );
                            },
                            isHelpdesk: isStaff,
                          ),
                          const SizedBox(height: 18),
                          HeroTicketCard(
                            ticket: ticket,
                            statusColor: statusColor,
                          ),
                          const SizedBox(height: 16),
                          InfoPanel(
                            ticket: ticket,
                            priorityColor: priorityColor,
                            statusColor: statusColor,
                          ),
                          const SizedBox(height: 16),
                          DescriptionPanel(description: ticket.description),
                          const SizedBox(height: 16),
                          TimelinePanel(ticket: ticket),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Get.toNamed(
                                  Routes.ticketTracking,
                                  arguments: ticket.id,
                                ),
                                icon: const Icon(Icons.analytics_outlined, size: 18),
                                label: const Text('Lihat Tracking Lengkap (Stepper)'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          HistoryLogPanel(controller: ctrl),
                          const SizedBox(height: 16),
                          CommentsPanel(
                            controller: ctrl,
                            authService: authService,
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  ComposerBar(ticketId: ticketId, controller: ctrl),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
