import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';

class NotificationPage extends GetView<NotificationProvider> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadSurface = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEFF4FF);
    final bodyTextColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);
    final metaTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final unread = controller.unreadCount.value;
          final suffix = unread > 0 ? ' ($unread)' : '';
          return Text('Notifikasi$suffix');
        }),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.unreadCount.value == 0
                  ? null
                  : controller.markAllAsRead,
              child: const Text('Tandai semua'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.notifications;
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada notifikasi'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Material(
              color: item.isRead
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : unreadSurface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  controller.markAsRead(item.id);
                  final ticketId = item.ticketId;
                  if (ticketId != null && ticketId.isNotEmpty) {
                    Get.toNamed(Routes.ticketDetail, arguments: ticketId);
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

