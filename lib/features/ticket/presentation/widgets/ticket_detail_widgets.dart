import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import '../providers/ticket_provider.dart';

class DetailBackdrop extends StatelessWidget {
  const DetailBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0B1220), Color(0xFF111827), Color(0xFF0F172A)]
              : const [Color(0xFFF7F8FF), Color(0xFFEFF4FF), Color(0xFFF9FBFF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.22),
                    const Color(0xFF2563EB).withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailTopBar extends StatelessWidget {
  final VoidCallback onMenu;
  final bool isHelpdesk;

  const DetailTopBar({super.key, required this.onMenu, required this.isHelpdesk});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF4338CA),
              size: 22,
            ),
            onPressed: Get.back,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Tiket',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Status, deskripsi, dan komentar dalam satu tampilan',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: mutedColor(context)),
              ),
            ],
          ),
        ),
        if (isHelpdesk)
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert_rounded, size: 22),
              onPressed: onMenu,
            ),
          ),
      ],
    );
  }
}

class HeroTicketCard extends StatelessWidget {
  final dynamic ticket;
  final Color statusColor;

  const HeroTicketCard({super.key, required this.ticket, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final heroStatusTextColor = ticket.status == 'closed'
        ? const Color(0xFFE2E8F0)
        : statusColor.withValues(alpha: 0.95);
    
    final ticketProvider = Get.find<TicketProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -8,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${ticket.id.toString().substring(0, 8)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(status: ticket.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Prioritas ${cap(ticket.priority)} dan kategori ${ticket.category} dipadatkan supaya lebih mudah dibaca.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: HeroMetric(
                      label: 'Status',
                      value: AppTheme.statusLabel(ticket.status),
                      color: heroStatusTextColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => HeroMetric(
                      label: 'Komentar',
                      value: '${ticketProvider.comments.length}',
                      color: Colors.white,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HeroMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  final dynamic ticket;
  final Color priorityColor;
  final Color statusColor;

  const InfoPanel({
    super.key,
    required this.ticket,
    required this.priorityColor,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi tiket',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 14),
          InfoRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: ticket.category,
          ),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.flag_outlined,
            label: 'Prioritas',
            value: cap(ticket.priority),
            valueColor: priorityColor,
          ),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Dilaporkan oleh',
            value: ticket.createdByName,
          ),
          if (ticket.assignedToName != null) ...[
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Ditangani oleh',
              value: ticket.assignedToName!,
            ),
          ],
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4338CA), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: valueColor ?? const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionPanel extends StatelessWidget {
  final String description;

  const DescriptionPanel({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              height: 1.55,
              fontSize: 13,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelinePanel extends StatelessWidget {
  final dynamic ticket;

  const TimelinePanel({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = ticket.status;
    final steps = [
      ('open', 'Tiket dibuka'),
      ('in_progress', 'Sedang dikerjakan'),
      ('resolved', 'Selesai Penanganan'),
      ('closed', 'Tiket ditutup'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++) ...[
            TimelineStep(
              label: steps[i].$2,
              isActive: _isActive(status, steps[i].$1),
              isCompleted: _isCompleted(status, steps[i].$1),
              isLast: i == steps.length - 1,
              time: _getStepTime(steps[i].$1),
            ),
          ],
        ],
      ),
    );
  }

  String? _getStepTime(String step) {
    final status = ticket.status;
    if (!_isCompleted(status, step)) return null;
    
    // Logic sederhana untuk menampilkan waktu update per status (simulasi data)
    if (step == 'open') return DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt);
    if (step == status) return DateFormat('dd MMM yyyy, HH:mm').format(ticket.updatedAt);
    
    // Status perantara jika sudah lewat
    return DateFormat('dd MMM yyyy, HH:mm').format(ticket.updatedAt.subtract(const Duration(minutes: 15)));
  }

  bool _isCompleted(String current, String step) {
    const order = ['open', 'in_progress', 'resolved', 'closed'];
    return order.indexOf(current) >= order.indexOf(step);
  }

  bool _isActive(String current, String step) => current == step;
}

class TimelineStep extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;
  final String? time;

  const TimelineStep({
    super.key,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? const Color(0xFF16A34A)
        : const Color(0xFFCBD5E1);
    final dotColor = isActive ? const Color(0xFF4F46E5) : color;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast) Container(width: 2, height: 42, color: color),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    time!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsPanel extends StatelessWidget {
  final TicketProvider controller;
  final AuthService authService;

  const CommentsPanel({super.key, required this.controller, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: panelBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.isLoadingComments.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.comments.isEmpty) {
                return const _EmptyCommentState();
              }

              return Column(
                children: [
                  for (final comment in controller.comments) ...[
                    CommentBubble(
                      comment: comment,
                      isCurrentUser:
                          comment.userId == authService.currentUser.value?.id,
                      isHelpdesk: authService.currentUser.value?.isStaff == true,
                      onReply: () => controller.prepareReply(comment.userName),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyCommentState extends StatelessWidget {
  const _EmptyCommentState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softBorderColor(context)),
      ),
      child: const Text(
        'Belum ada komentar untuk tiket ini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
      ),
    );
  }
}

class CommentBubble extends StatelessWidget {
  final dynamic comment;
  final bool isCurrentUser;
  final bool isHelpdesk;
  final VoidCallback onReply;

  const CommentBubble({
    super.key,
    required this.comment,
    required this.isCurrentUser,
    required this.isHelpdesk,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final background = isCurrentUser
        ? const Color(0xFF4F46E5)
        : const Color(0xFFF8FAFF);
    final foreground = isCurrentUser ? Colors.white : const Color(0xFF0F172A);
    final subForeground = isCurrentUser
        ? Colors.white70
        : const Color(0xFF64748B);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentUser ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF0F172A,
              ).withValues(alpha: isCurrentUser ? 0.14 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.userName,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.white.withValues(alpha: 0.18)
                        : const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    cap(comment.userRole),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : const Color(0xFF4338CA),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.content,
              style: TextStyle(color: foreground, height: 1.45, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormat('HH:mm, dd MMM').format(comment.createdAt),
                  style: TextStyle(
                    color: subForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isHelpdesk)
                  TextButton.icon(
                    onPressed: onReply,
                    icon: const Icon(Icons.reply_rounded, size: 14),
                    label: const Text('Balas'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: isCurrentUser
                          ? Colors.white
                          : const Color(0xFF4338CA),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(
          AppTheme.statusLabel(status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class ComposerBar extends StatelessWidget {
  final String ticketId;
  final TicketProvider controller;

  const ComposerBar({super.key, required this.ticketId, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentCtrl,
              decoration: const InputDecoration(
                hintText: 'Balas komentar atau tulis interaksi...',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => IconButton.filled(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.addComment(ticketId),
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showActionMenu(
  BuildContext context,
  TicketProvider ctrl,
  String ticketId,
  AuthService authService,
) async {
  final ticket = ctrl.selectedTicket.value;
  final actor = authService.currentUser.value;

  if (ticket == null || actor == null) {
    Get.snackbar('Info', 'Data tiket tidak tersedia');
    return;
  }

  final isAdmin = actor.isAdmin;
  final isHelpdesk = actor.role == 'helpdesk';
  final isTechnicalSupport = actor.isTechnicalSupport;
  final isAssignedToMe = ticket.assignedTo == actor.id;
  final technicalSupports = authService.technicalSupportUsers;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin || isHelpdesk)
              ListTile(
                leading: const Icon(Icons.timelapse_rounded),
                title: const Text('Set Diproses'),
                onTap: () {
                  Get.back();
                  ctrl.updateStatus(ticketId, 'in_progress');
                },
              ),
            if (isAdmin || (isTechnicalSupport && isAssignedToMe))
              ListTile(
                leading: const Icon(Icons.verified_rounded),
                title: const Text('Set Selesai Penanganan'),
                onTap: () {
                  Get.back();
                  ctrl.updateStatus(ticketId, 'resolved');
                },
              ),
            if (isAdmin || isHelpdesk)
              ListTile(
                leading: const Icon(Icons.lock_rounded),
                title: const Text('Close Ticket (Selesai)'),
                onTap: () {
                  Get.back();
                  ctrl.updateStatus(ticketId, 'closed');
                },
              ),
            if (isAdmin || isHelpdesk) const Divider(),
            if ((isAdmin || isHelpdesk) && ticket.assignedTo == null)
              ListTile(
                leading: const Icon(Icons.assignment_ind_outlined),
                title: const Text('Assign ke Technical Support'),
                onTap: () {
                  Get.back();
                  _showAssignDialog(
                    context,
                    ctrl,
                    ticketId,
                    technicalSupports,
                    title: 'Assign Technical Support',
                  );
                },
              ),
            if (isAdmin && ticket.assignedTo != null)
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded),
                title: const Text('Re-assign Technical Support'),
                onTap: () {
                  Get.back();
                  _showAssignDialog(
                    context,
                    ctrl,
                    ticketId,
                    technicalSupports,
                    title: 'Re-assign Technical Support',
                  );
                },
              ),
            if (isAdmin && ticket.assignedTo != null)
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: const Text('Batalkan Assign'),
                onTap: () {
                  Get.back();
                  _showUnassignConfirm(ctrl, ticketId);
                },
              ),
          ],
        ),
      );
    },
  );
}

Future<void> _showAssignDialog(
  BuildContext context,
  TicketProvider ctrl,
  String ticketId,
  List<UserModel> assignableUsers, {
  String title = 'Assign Tiket',
}) async {
  if (assignableUsers.isEmpty) {
    Get.snackbar('Info', 'Belum ada technical support yang bisa di-assign');
    return;
  }

  var selectedUser = assignableUsers.first;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 320,
              child: DropdownButtonFormField<UserModel>(
                value: selectedUser,
                isExpanded: true,
                menuMaxHeight: 280,
                decoration: const InputDecoration(
                  labelText: 'Pilih technical support',
                ),
                items: [
                  for (final user in assignableUsers)
                    DropdownMenuItem<UserModel>(
                      value: user,
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedUser = value);
                  }
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.assignTicket(ticketId, selectedUser.id, selectedUser.name);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _showUnassignConfirm(
  TicketProvider ctrl,
  String ticketId,
) async {
  final agree = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Batalkan Assign?'),
      content: const Text(
        'Tiket akan kembali ke status menunggu helpdesk dan teknisi saat ini dilepas.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Tidak'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Ya, Batalkan'),
        ),
      ],
    ),
  );

  if (agree == true) {
    ctrl.unassignTicket(ticketId);
  }
}

String cap(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

Color panelColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const Color(0xFF111827).withValues(alpha: 0.92)
      : Colors.white.withValues(alpha: 0.90);
}

Color panelBorderColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? scheme.outlineVariant.withValues(alpha: 0.72)
      : scheme.outlineVariant.withValues(alpha: 0.55);
}

Color softSurfaceColor(BuildContext context) {
  return Theme.of(context).colorScheme.surfaceContainerHighest;
}

Color softBorderColor(BuildContext context) {
  return Theme.of(context).colorScheme.outlineVariant;
}

Color titleColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

Color mutedColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}
