import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import '../providers/ticket_provider.dart';

class TrackingTicketScreen extends StatelessWidget {
  const TrackingTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<TicketProvider>();
    final String ticketId = Get.arguments as String;

    // Load logs if not already loaded or refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadTicketDetail(ticketId);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tracking Aktivitas Tiket'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Obx(() {
        if (ctrl.isLoadingLogs.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.ticketLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Belum ada riwayat aktivitas.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Semua perubahan status dan penugasan akan tercatat secara otomatis di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadTicketDetail(ticketId),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            itemCount: ctrl.ticketLogs.length,
            itemBuilder: (context, index) {
              final log = ctrl.ticketLogs[index];
              final isFirst = index == 0;
              final isLast = index == ctrl.ticketLogs.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Timeline
                  Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AppTheme.statusColor(log.newStatus)
                              : Theme.of(context).colorScheme.outlineVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 4,
                          ),
                          boxShadow: isFirst
                              ? [
                                  BoxShadow(
                                    color: AppTheme.statusColor(log.newStatus)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        child: isFirst
                            ? const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isFirst
                                    ? AppTheme.statusColor(log.newStatus)
                                    : Theme.of(context).colorScheme.outlineVariant,
                                Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Content Card
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy').format(log.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? AppTheme.statusColor(log.newStatus)
                                    .withValues(alpha: 0.08)
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isFirst
                                  ? AppTheme.statusColor(log.newStatus)
                                      .withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.statusColor(log.newStatus),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppTheme.statusLabel(log.newStatus),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('HH:mm').format(log.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Text(
                                "Status diperbarui dari ${log.oldStatus.toUpperCase()} ke ${log.newStatus.toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                log.note ?? "Tidak ada catatan tambahan.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_circle_outlined,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Oleh: ${log.changedByName}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
