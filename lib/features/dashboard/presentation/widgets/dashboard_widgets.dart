import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';

class DashboardBackdrop extends StatelessWidget {
  const DashboardBackdrop({super.key});

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
            top: -90,
            right: -60,
            child: BackdropOrb(
              size: 220,
              colors: [
                const Color(0xFF7C3AED).withValues(alpha: 0.22),
                const Color(0xFF2563EB).withValues(alpha: 0.05),
              ],
            ),
          ),
          Positioned(
            top: 140,
            left: -100,
            child: BackdropOrb(
              size: 180,
              colors: [
                const Color(0xFF22C55E).withValues(alpha: 0.12),
                const Color(0xFF38BDF8).withValues(alpha: 0.04),
              ],
            ),
          ),
          Positioned(
            bottom: 120,
            right: -80,
            child: BackdropOrb(
              size: 200,
              colors: [
                const Color(0xFFEC4899).withValues(alpha: 0.10),
                const Color(0xFFF59E0B).withValues(alpha: 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackdropOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const BackdropOrb({super.key, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class DashboardTopBar extends StatelessWidget {
  final String userName;
  final String role;

  const DashboardTopBar({super.key, required this.userName, required this.role});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: softSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: softBorderColor(context)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.dashboard_rounded,
            color: titleColor(context),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard $role',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DashboardActionIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: unread,
          onTap: () => Get.toNamed(Routes.notifications),
        ),
        const SizedBox(width: 8),
        DashboardActionIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => Get.toNamed(Routes.profile),
        ),
      ],
    );
  }
}

class DashboardActionIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const DashboardActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: softSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: softBorderColor(context)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(icon, color: titleColor(context), size: 22),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    child: Text(
                      badgeCount > 99 ? '99+' : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  final String greeting;
  final String userName;
  final String role;
  final int totalTickets;
  final int openTickets;

  const HeroPanel({
    super.key,
    required this.greeting,
    required this.userName,
    required this.role,
    required this.totalTickets,
    required this.openTickets,
  });

  @override
  Widget build(BuildContext context) {
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
            top: -24,
            right: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -36,
            left: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Text(
                  '$greeting, $role',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Halo, $userName!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lihat status tiket, pantau antrian, dan akses menu penting tanpa tampilan yang kaku.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MiniInfoCard(
                      label: 'Total tiket',
                      value: totalTickets.toString(),
                      icon: Icons.confirmation_number_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniInfoCard(
                      label: 'Open',
                      value: openTickets.toString(),
                      icon: Icons.local_fire_department_outlined,
                    ),
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

class MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const MiniInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
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

class RoleMetricsPanel extends StatelessWidget {
  final bool isUser;
  final Map<String, int> metrics;

  const RoleMetricsPanel({super.key, required this.isUser, required this.metrics});

  void _openTicketList(BuildContext context, String filter, {String? note}) {
    context.read<TicketProvider>().setFilter(filter);
    Get.toNamed(Routes.ticketList);

    if (note != null && note.trim().isNotEmpty) {
      Get.snackbar(
        'Info',
        note,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = isUser
        ? [
            RoleMetricData(
              label: 'Sudah Ajukan',
              value: metrics['submitted'] ?? 0,
              icon: Icons.upload_file_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => _openTicketList(context, 'all'),
            ),
            RoleMetricData(
              label: 'On Going',
              value: metrics['ongoing'] ?? 0,
              icon: Icons.timelapse_rounded,
              color: const Color(0xFFD97706),
              onTap: () => _openTicketList(context, 'in_progress'),
            ),
            RoleMetricData(
              label: 'Finish',
              value: metrics['finish'] ?? 0,
              icon: Icons.verified_rounded,
              color: const Color(0xFF16A34A),
              onTap: () => _openTicketList(context, 'closed'),
            ),
          ]
        : [
            RoleMetricData(
              label: 'Ticket Masuk',
              value: metrics['ticket_in'] ?? 0,
              icon: Icons.move_to_inbox_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => _openTicketList(context, 'all'),
            ),
            RoleMetricData(
              label: 'On Going',
              value: metrics['ongoing'] ?? 0,
              icon: Icons.timelapse_rounded,
              color: const Color(0xFFD97706),
              onTap: () => _openTicketList(context, 'in_progress'),
            ),
            RoleMetricData(
              label: 'Belum Ditangani',
              value: metrics['unhandled'] ?? 0,
              icon: Icons.pending_actions_rounded,
              color: const Color(0xFF7C3AED),
              onTap: () => _openTicketList(
                context,
                'open',
                note:
                    'Menampilkan tiket Open. Untuk melihat yang belum ditangani, cek tiket yang belum ada assignee.',
              ),
            ),
            RoleMetricData(
              label: 'Finish Approved',
              value: metrics['approved_finish'] ?? 0,
              icon: Icons.approval_rounded,
              color: const Color(0xFF16A34A),
              onTap: () => _openTicketList(context, 'closed'),
            ),
            RoleMetricData(
              label: 'Total Masuk',
              value: metrics['total_incoming'] ?? 0,
              icon: Icons.confirmation_number_rounded,
              color: const Color(0xFF0EA5E9),
              onTap: () => _openTicketList(context, 'all'),
            ),
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
            isUser
                ? 'Informasi Dashboard User'
                : 'Informasi Dashboard Admin/Helpdesk',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUser
                ? 'Klik kartu untuk melihat tiket terkait.'
                : 'Klik kartu untuk membuka tiket sesuai kategorinya.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: mutedColor(context)),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isUser ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: isUser ? 130 : 116,
            ),
            itemBuilder: (context, index) {
              return RoleMetricTile(item: items[index]);
            },
          ),
        ],
      ),
    );
  }
}

class RoleMetricData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RoleMetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class RoleMetricTile extends StatelessWidget {
  final RoleMetricData item;

  const RoleMetricTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: softSurfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: softBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.value}',
                style: TextStyle(
                  color: titleColor(context),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: mutedColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SnapshotPanel extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const SnapshotPanel({
    super.key,
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan aktivitas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Statistik tiket helpdesk untuk periode saat ini',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Bulan ini',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF4338CA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 420) {
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: StatusRingChart(
                        total: total,
                        open: open,
                        inProgress: inProgress,
                        resolved: resolved,
                        closed: closed,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 4,
                      child: StatusLegend(
                        total: total,
                        open: open,
                        inProgress: inProgress,
                        resolved: resolved,
                        closed: closed,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  StatusRingChart(
                    total: total,
                    open: open,
                    inProgress: inProgress,
                    resolved: resolved,
                    closed: closed,
                  ),
                  const SizedBox(height: 16),
                  StatusLegend(
                    total: total,
                    open: open,
                    inProgress: inProgress,
                    resolved: resolved,
                    closed: closed,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatusRingChart extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const StatusRingChart({
    super.key,
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4F46E5);

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 190,
            height: 190,
            child: CustomPaint(
              painter: RingChartPainter(
                total: total,
                segments: [
                  ChartSegment(open, AppTheme.statusColor('open')),
                  ChartSegment(
                    inProgress,
                    AppTheme.statusColor('in_progress'),
                  ),
                  ChartSegment(resolved, AppTheme.statusColor('resolved')),
                  ChartSegment(closed, AppTheme.statusColor('closed')),
                ],
              ),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total tiket',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
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

class ChartSegment {
  final int value;
  final Color color;

  const ChartSegment(this.value, this.color);
}

class RingChartPainter extends CustomPainter {
  final int total;
  final List<ChartSegment> segments;

  RingChartPainter({required this.total, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 14,
    );
    const startAngle = -math.pi / 2;
    const strokeWidth = 24.0;
    const gap = 0.06;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE5E7EB)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    if (total <= 0) {
      return;
    }

    var currentAngle = startAngle;
    for (final segment in segments) {
      if (segment.value <= 0) {
        continue;
      }
      final sweep = (segment.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(
        rect,
        currentAngle,
        math.max(sweep - gap, 0.02),
        false,
        paint,
      );
      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant RingChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.segments != segments;
  }
}

class StatusLegend extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const StatusLegend({
    super.key,
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LegendRow(
          label: 'Open',
          value: open,
          color: AppTheme.statusColor('open'),
          hint: _ratioText(open),
        ),
        const SizedBox(height: 12),
        LegendRow(
          label: 'In Progress',
          value: inProgress,
          color: AppTheme.statusColor('in_progress'),
          hint: _ratioText(inProgress),
        ),
        const SizedBox(height: 12),
        LegendRow(
          label: 'Resolved',
          value: resolved,
          color: AppTheme.statusColor('resolved'),
          hint: _ratioText(resolved),
        ),
        const SizedBox(height: 12),
        LegendRow(
          label: 'Closed',
          value: closed,
          color: AppTheme.statusColor('closed'),
          hint: _ratioText(closed),
        ),
      ],
    );
  }

  String _ratioText(int value) {
    if (total <= 0) {
      return '0%';
    }
    return '${((value / total) * 100).round()}%';
  }
}

class LegendRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String hint;

  const LegendRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsPanel extends StatelessWidget {
  final bool canCreateTicket;
  final VoidCallback onTickets;
  final VoidCallback? onCreateTicket;
  final VoidCallback onProfile;
  final Future<void> Function() onRefresh;

  const QuickActionsPanel({
    super.key,
    required this.canCreateTicket,
    required this.onTickets,
    required this.onCreateTicket,
    required this.onProfile,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <QuickActionItem>[
      QuickActionItem(
        title: 'Tiket',
        subtitle: 'Lihat daftar',
        icon: Icons.list_alt_rounded,
        gradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        onTap: onTickets,
      ),
      QuickActionItem(
        title: 'Buat tiket',
        subtitle: canCreateTicket ? 'Buka form' : 'Tidak tersedia',
        icon: Icons.add_circle_outline_rounded,
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        onTap: onCreateTicket,
        disabled: !canCreateTicket,
      ),
      QuickActionItem(
        title: 'Profil',
        subtitle: 'Akun saya',
        icon: Icons.person_rounded,
        gradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
        onTap: onProfile,
      ),
      QuickActionItem(
        title: 'Refresh',
        subtitle: 'Sinkron data',
        icon: Icons.refresh_rounded,
        gradient: const [Color(0xFF6D28D9), Color(0xFF4C1D95)],
        onTap: onRefresh,
      ),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Menu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Akses aksi yang paling sering dipakai',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onTickets, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: actions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.10,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return QuickActionTile(item: action);
            },
          ),
        ],
      ),
    );
  }
}

class QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool disabled;

  const QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.disabled = false,
  });
}

class QuickActionTile extends StatelessWidget {
  final QuickActionItem item;

  const QuickActionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.disabled
              ? [const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)]
              : item.gradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (item.gradient.first).withValues(
              alpha: item.disabled ? 0.04 : 0.20,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: item.disabled ? 0.65 : 0.18,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.disabled ? const Color(0xFF94A3B8) : Colors.white,
              size: 22,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: item.disabled ? const Color(0xFF64748B) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: item.disabled
                      ? const Color(0xFF94A3B8)
                      : Colors.white.withValues(alpha: 0.88),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: item.disabled ? null : item.onTap,
        child: Opacity(opacity: item.disabled ? 0.72 : 1, child: tile),
      ),
    );
  }
}

class RecentTicketsPanel extends StatelessWidget {
  const RecentTicketsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = context.read<TicketProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: softBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiket Terbaru',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor(context),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.ticketList),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: ticketCtrl,
            builder: (context, _) {
              if (ticketCtrl.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final recent = ticketCtrl.tickets.take(5).toList();
              if (recent.isEmpty) {
                return const EmptyRecentTickets();
              }

              return Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    RecentTicketTile(ticket: recent[i]),
                    if (i != recent.length - 1) const SizedBox(height: 10),
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

class EmptyRecentTickets extends StatelessWidget {
  const EmptyRecentTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softBorderColor(context)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 42, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            'Belum ada tiket terbaru',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saat ada tiket baru, semuanya akan muncul di sini.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: mutedColor(context)),
          ),
        ],
      ),
    );
  }
}

class RecentTicketTile extends StatelessWidget {
  final TicketModel ticket;

  const RecentTicketTile({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(ticket.status);
    final priorityColor = AppTheme.priorityColor(ticket.priority);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed(Routes.ticketDetail, arguments: ticket.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: softSurfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: softBorderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.confirmation_number_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket.category} | ${_formatDate(ticket.updatedAt)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Pill(
                          text: AppTheme.statusLabel(ticket.status),
                          background: statusColor.withValues(alpha: 0.10),
                          foreground: statusColor,
                        ),
                        Pill(
                          text: ticket.priority.toUpperCase(),
                          background: priorityColor.withValues(alpha: 0.10),
                          foreground: priorityColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const Pill({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class DashboardBottomNav extends StatefulWidget {
  const DashboardBottomNav({super.key});

  @override
  State<DashboardBottomNav> createState() => _DashboardBottomNavState();
}

class _DashboardBottomNavState extends State<DashboardBottomNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) {
        setState(() => _index = i);
        if (i == 1) Get.toNamed(Routes.ticketList);
        if (i == 2) Get.toNamed(Routes.profile);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: 'Tiket',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}

String formatRole(String role) {
  if (role.isEmpty) return 'Pengguna';
  final normalized = role.replaceAll('_', ' ');
  final words = normalized.split(' ');
  return words
      .where((word) => word.trim().isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day $month, $hour:$minute';
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
