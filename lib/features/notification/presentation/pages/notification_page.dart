import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import '../widgets/notification_widgets.dart';

class NotificationPage extends GetView<NotificationProvider> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final bodyTextColor = scheme.onSurface;
    final metaTextColor = scheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final unread = controller.unreadCount;
            final suffix = unread > 0 ? ' ($unread)' : '';
            return Text('Notifikasi$suffix');
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => TextButton(
              onPressed: controller.unreadCount == 0 ? null : controller.markAllAsRead,
              child: const Text('Tandai semua'),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.notifications;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return NotificationItem(
                item: items[index],
                isUnreadSurface: isDark,
                bodyTextColor: bodyTextColor,
                metaTextColor: metaTextColor,
                onMarkAsRead: controller.markAsRead,
              );
            },
          );
        },
      ),
    );
  }
}
