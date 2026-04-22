import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = context.watch<DashboardProvider>();
    final authService = context.read<AuthService>();
    final user = authService.currentUser.value;
    final userName = user?.name ?? 'Pengguna';
    final role = _formatRole(user?.role ?? '');
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
          const _DashboardBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                _TopBar(userName: userName, role: role),
                const SizedBox(height: 18),
                _HeroPanel(
                  greeting: dashCtrl.greeting,
                  userName: userName,
                  role: role,
                  totalTickets: total,
                  openTickets: open,
                ),
                const SizedBox(height: 16),
                _RoleMetricsPanel(
                  isUser: user?.isUser == true,
                  metrics: roleMetrics,
                ),
                const SizedBox(height: 16),
                _SnapshotPanel(
                  total: total,
                  open: open,
                  inProgress: inProgress,
                  resolved: resolved,
                  closed: closed,
                ),
                const SizedBox(height: 16),
                _QuickActionsPanel(
                  canCreateTicket: user?.isUser == true,
                  onTickets: () => Get.toNamed(Routes.ticketList),
                  onCreateTicket: user?.isUser == true
                      ? () => Get.toNamed(Routes.ticketCreate)
                      : null,
                  onProfile: () => Get.toNamed(Routes.profile),
                  onRefresh: () async {
                    final ticketProvider = context.read<TicketProvider>();
                    final scheme = Theme.of(context).colorScheme;
                    await dashCtrl.loadStats();
                    await ticketProvider.loadTickets();
                    Get.snackbar(
                      'Diperbarui',
                      'Statistik dan daftar tiket sudah disegarkan',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: scheme.inverseSurface,
                      colorText: scheme.onInverseSurface,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const _RecentTicketsPanel(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
      floatingActionButton: (user?.isUser == true)
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.ticketCreate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Tiket'),
            )
          : null,
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

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
            child: _BackdropOrb(
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
            child: _BackdropOrb(
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
            child: _BackdropOrb(
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

class _BackdropOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _BackdropOrb({required this.size, required this.colors});

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

class _TopBar extends StatelessWidget {
  final String userName;
  final String role;

  const _TopBar({required this.userName, required this.role});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _softSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _softBorderColor(context)),
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
            color: _titleColor(context),
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
                  color: _titleColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _mutedColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),        _ActionIconButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: unread,
            onTap: () => Get.toNamed(Routes.notifications),
                    ),
        const SizedBox(width: 8),
        _ActionIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => Get.toNamed(Routes.profile),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _softSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _softBorderColor(context)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(icon, color: _titleColor(context), size: 22),
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

class _HeroPanel extends StatelessWidget {
  final String greeting;
  final String userName;
  final String role;
  final int totalTickets;
  final int openTickets;

  const _HeroPanel({
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
                    child: _MiniInfoCard(
                      label: 'Total tiket',
                      value: totalTickets.toString(),
                      icon: Icons.confirmation_number_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInfoCard(
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

class _MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniInfoCard({
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

class _RoleMetricsPanel extends StatelessWidget {
  final bool isUser;
  final Map<String, int> metrics;

  const _RoleMetricsPanel({required this.isUser, required this.metrics});

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
            _RoleMetricData(
              label: 'Sudah Ajukan',
              value: metrics['submitted'] ?? 0,
              icon: Icons.upload_file_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => _openTicketList(context, 'all'),
            ),
            _RoleMetricData(
              label: 'On Going',
              value: metrics['ongoing'] ?? 0,
              icon: Icons.timelapse_rounded,
              color: const Color(0xFFD97706),
              onTap: () => _openTicketList(context, 'in_progress'),
            ),
            _RoleMetricData(
              label: 'Finish',
              value: metrics['finish'] ?? 0,
              icon: Icons.verified_rounded,
              color: const Color(0xFF16A34A),
              onTap: () => _openTicketList(context, 'closed'),
            ),
          ]
        : [
            _RoleMetricData(
              label: 'Ticket Masuk',
              value: metrics['ticket_in'] ?? 0,
              icon: Icons.move_to_inbox_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => _openTicketList(context, 'all'),
            ),
            _RoleMetricData(
              label: 'On Going',
              value: metrics['ongoing'] ?? 0,
              icon: Icons.timelapse_rounded,
              color: const Color(0xFFD97706),
              onTap: () => _openTicketList(context, 'in_progress'),
            ),
            _RoleMetricData(
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
            _RoleMetricData(
              label: 'Finish Approved',
              value: metrics['approved_finish'] ?? 0,
              icon: Icons.approval_rounded,
              color: const Color(0xFF16A34A),
              onTap: () => _openTicketList(context, 'closed'),
            ),
            _RoleMetricData(
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
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _panelBorderColor(context)),
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
              color: _titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUser
                ? 'Klik kartu untuk melihat tiket terkait.'
                : 'Klik kartu untuk membuka tiket sesuai kategorinya.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
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
              return _RoleMetricTile(item: items[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _RoleMetricData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleMetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _RoleMetricTile extends StatelessWidget {
  final _RoleMetricData item;

  const _RoleMetricTile({required this.item});

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
            color: _softSurfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _softBorderColor(context)),
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
                  color: _titleColor(context),
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
                  color: _mutedColor(context),
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

class _SnapshotPanel extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const _SnapshotPanel({
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
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _panelBorderColor(context)),
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
                        color: _titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Statistik tiket helpdesk untuk periode saat ini',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor(context),
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
                      child: _StatusRingChart(
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
                      child: _StatusLegend(
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
                  _StatusRingChart(
                    total: total,
                    open: open,
                    inProgress: inProgress,
                    resolved: resolved,
                    closed: closed,
                  ),
                  const SizedBox(height: 16),
                  _StatusLegend(
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

class _StatusRingChart extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const _StatusRingChart({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4F46E5);

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 190,
            height: 190,
            child: CustomPaint(
              painter: _RingChartPainter(
                total: total,
                segments: [
                  _ChartSegment(open, AppTheme.statusColor('open')),
                  _ChartSegment(
                    inProgress,
                    AppTheme.statusColor('in_progress'),
                  ),
                  _ChartSegment(resolved, AppTheme.statusColor('resolved')),
                  _ChartSegment(closed, AppTheme.statusColor('closed')),
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

class _ChartSegment {
  final int value;
  final Color color;

  const _ChartSegment(this.value, this.color);
}

class _RingChartPainter extends CustomPainter {
  final int total;
  final List<_ChartSegment> segments;

  _RingChartPainter({required this.total, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 14,
    );
    final startAngle = -math.pi / 2;
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
  bool shouldRepaint(covariant _RingChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.segments != segments;
  }
}

class _StatusLegend extends StatelessWidget {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const _StatusLegend({
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
        _LegendRow(
          label: 'Open',
          value: open,
          color: AppTheme.statusColor('open'),
          hint: _ratioText(open),
        ),
        const SizedBox(height: 12),
        _LegendRow(
          label: 'In Progress',
          value: inProgress,
          color: AppTheme.statusColor('in_progress'),
          hint: _ratioText(inProgress),
        ),
        const SizedBox(height: 12),
        _LegendRow(
          label: 'Resolved',
          value: resolved,
          color: AppTheme.statusColor('resolved'),
          hint: _ratioText(resolved),
        ),
        const SizedBox(height: 12),
        _LegendRow(
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

class _LegendRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String hint;

  const _LegendRow({
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
        color: _softSurfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softBorderColor(context)),
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

class _QuickActionsPanel extends StatelessWidget {
  final bool canCreateTicket;
  final VoidCallback onTickets;
  final VoidCallback? onCreateTicket;
  final VoidCallback onProfile;
  final Future<void> Function() onRefresh;

  const _QuickActionsPanel({
    required this.canCreateTicket,
    required this.onTickets,
    required this.onCreateTicket,
    required this.onProfile,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        title: 'Tiket',
        subtitle: 'Lihat daftar',
        icon: Icons.list_alt_rounded,
        gradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        onTap: onTickets,
      ),
      _QuickActionItem(
        title: 'Buat tiket',
        subtitle: canCreateTicket ? 'Buka form' : 'Tidak tersedia',
        icon: Icons.add_circle_outline_rounded,
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        onTap: onCreateTicket,
        disabled: !canCreateTicket,
      ),
      _QuickActionItem(
        title: 'Profil',
        subtitle: 'Akun saya',
        icon: Icons.person_rounded,
        gradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
        onTap: onProfile,
      ),
      _QuickActionItem(
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
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _panelBorderColor(context)),
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
                        color: _titleColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Akses aksi yang paling sering dipakai',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedColor(context),
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
              return _QuickActionTile(item: action);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool disabled;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.disabled = false,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionItem item;

  const _QuickActionTile({required this.item});

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

class _RecentTicketsPanel extends StatelessWidget {
  const _RecentTicketsPanel();

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = context.read<TicketProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _softSurfaceColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _softBorderColor(context)),
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
                  color: _titleColor(context),
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
                return const _EmptyRecentTickets();
              }

              return Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    _RecentTicketTile(ticket: recent[i]),
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

class _EmptyRecentTickets extends StatelessWidget {
  const _EmptyRecentTickets();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _softSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorderColor(context)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 42, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            'Belum ada tiket terbaru',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: _titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saat ada tiket baru, semuanya akan muncul di sini.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
          ),
        ],
      ),
    );
  }
}

class _RecentTicketTile extends StatelessWidget {
  final TicketModel ticket;

  const _RecentTicketTile({required this.ticket});

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
            color: _softSurfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _softBorderColor(context)),
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
                        _Pill(
                          text: AppTheme.statusLabel(ticket.status),
                          background: statusColor.withValues(alpha: 0.10),
                          foreground: statusColor,
                        ),
                        _Pill(
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

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _Pill({
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

class _BottomNav extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
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

String _formatRole(String role) {
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

Color _panelColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const Color(0xFF111827).withValues(alpha: 0.92)
      : Colors.white.withValues(alpha: 0.90);
}

Color _panelBorderColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? scheme.outlineVariant.withValues(alpha: 0.72)
      : scheme.outlineVariant.withValues(alpha: 0.55);
}

Color _softSurfaceColor(BuildContext context) {
  return Theme.of(context).colorScheme.surfaceContainerHighest;
}

Color _softBorderColor(BuildContext context) {
  return Theme.of(context).colorScheme.outlineVariant;
}

Color _titleColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

Color _mutedColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}
































