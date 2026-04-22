import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';

class NotificationPage extends GetView<NotificationProvider> {  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final unreadSurface = isDark
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerHighest;
    final bodyTextColor = scheme.onSurface;
    final metaTextColor = scheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(animation: controller, builder: (context, _) {
          final unread = controller.unreadCount;
          final suffix = unread > 0 ? ' ($unread)' : '';
          return Text('Notifikasi$suffix');
        }),
        actions: [
          AnimatedBuilder(animation: controller, builder: (context, _) => TextButton(
              onPressed: controller.unreadCount == 0
                  ? null
                  : controller.markAllAsRead,
              child: const Text('Tandai semua'),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(animation: controller, builder: (context, _) {        final items = controller.notifications;
        if (items.isEmpty) {          return const Center(child: Text('Belum ada notifikasi'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {            final item = items[index];
            return Material(
              color: item.isRead
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : unreadSurface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {                  controller.markAsRead(item.id);
                  final ticketId = item.ticketId;
                  if (ticketId != null && ticketId.isNotEmpty) {                    Get.toNamed(Routes.ticketDetail, arguments: ticketId);
                    return;
                  }

                  Get.snackbar(
                    item.title,
                    item.message,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? Colors.transparent
                              : const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: TextStyle(color: bodyTextColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt),
                              style: TextStyle(
                                color: metaTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}









