import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';

class NotificationItem extends StatelessWidget {
  final dynamic item;
  final bool isUnreadSurface;
  final Color bodyTextColor;
  final Color metaTextColor;
  final Function(String) onMarkAsRead;

  const NotificationItem({
    super.key,
    required this.item,
    required this.isUnreadSurface,
    required this.bodyTextColor,
    required this.metaTextColor,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : (isUnreadSurface 
              ? Theme.of(context).colorScheme.surfaceContainerLow 
              : Theme.of(context).colorScheme.surfaceContainerHighest),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          onMarkAsRead(item.id);
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
                  color: item.isRead ? Colors.transparent : const Color(0xFF2563EB),
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
  }
}
