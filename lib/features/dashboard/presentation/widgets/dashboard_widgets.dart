import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import 'package:e_ticketing_helpdesk/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';

class DashboardBackdrop extends StatelessWidget {
  const DashboardBackdrop({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: Theme.of(context).brightness == Brightness.dark
            ? const [Color(0xFF0B1220), Color(0xFF111827), Color(0xFF0F172A)]
            : const [Color(0xFFF7F8FF), Color(0xFFEFF4FF), Color(0xFFF9FBFF)],
      ),
    ),
  );
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
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: softSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: softBorderColor(context)),
          ),
          child: Icon(Icons.dashboard_rounded, color: titleColor(context), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard $role', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: titleColor(context))),
              const SizedBox(height: 2),
              Text(userName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mutedColor(context), fontWeight: FontWeight.w500)),
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
  const DashboardActionIconButton({super.key, required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: softSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: softBorderColor(context))),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(alignment: Alignment.center, child: Icon(icon, color: titleColor(context), size: 22)),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, height: 1),
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
  const HeroPanel({super.key, required this.greeting, required this.userName, required this.role, required this.totalTickets, required this.openTickets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF2563EB)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting, $role', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Halo, $userName!', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: MiniInfoCard(label: 'Total tiket', value: totalTickets.toString(), icon: Icons.confirmation_number_outlined)),
              const SizedBox(width: 12),
              Expanded(child: MiniInfoCard(label: 'Open', value: openTickets.toString(), icon: Icons.local_fire_department_outlined)),
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
  const MiniInfoCard({super.key, required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Icon(icon, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    ]),
  );
}

class RoleMetricsPanel extends StatelessWidget {
  final UserModel? user;
  final Map<String, int> metrics;
  const RoleMetricsPanel({super.key, required this.user, required this.metrics});

  @override
  Widget build(BuildContext context) {
    List<RoleMetricData> items = [];
    String panelTitle = 'Informasi Dashboard';

    if (user?.isAdmin == true) {
      panelTitle += ' Admin';
      items = [
        RoleMetricData(label: 'Total Masuk', value: metrics['total_incoming'] ?? 0, icon: Icons.analytics_rounded, color: const Color(0xFF2563EB)),
        RoleMetricData(label: 'Belum Handle', value: metrics['unhandled'] ?? 0, icon: Icons.warning_amber_rounded, color: const Color(0xFFDC2626)),
        RoleMetricData(label: 'On Going', value: metrics['ongoing'] ?? 0, icon: Icons.sync_rounded, color: const Color(0xFFD97706)),
        RoleMetricData(label: 'Selesai', value: metrics['approved_finish'] ?? 0, icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A)),
      ];
    } else if (user?.isUser == true) {
      panelTitle += ' User';
      items = [
        RoleMetricData(label: 'Sudah Ajukan', value: metrics['submitted'] ?? 0, icon: Icons.upload_file_rounded, color: const Color(0xFF2563EB)),
        RoleMetricData(label: 'On Going', value: metrics['ongoing'] ?? 0, icon: Icons.timelapse_rounded, color: const Color(0xFFD97706)),
        RoleMetricData(label: 'Finish', value: metrics['finish'] ?? 0, icon: Icons.verified_rounded, color: const Color(0xFF16A34A)),
      ];
    } else if (user?.isTechnicalSupport == true) {
      panelTitle += ' Technical Support';
      items = [
        RoleMetricData(label: 'Tugas Saya', value: metrics['my_tasks'] ?? 0, icon: Icons.assignment_ind_rounded, color: const Color(0xFF2563EB)),
        RoleMetricData(label: 'Sedang Dikerjakan', value: metrics['ongoing'] ?? 0, icon: Icons.handyman_rounded, color: const Color(0xFFD97706)),
        RoleMetricData(label: 'Sudah Selesai', value: metrics['resolved'] ?? 0, icon: Icons.task_alt_rounded, color: const Color(0xFF16A34A)),
      ];
    } else {
      panelTitle += ' Helpdesk';
      items = [
        RoleMetricData(label: 'Ticket Masuk', value: metrics['ticket_in'] ?? 0, icon: Icons.move_to_inbox_rounded, color: const Color(0xFF2563EB)),
        RoleMetricData(label: 'On Going', value: metrics['ongoing'] ?? 0, icon: Icons.timelapse_rounded, color: const Color(0xFFD97706)),
        RoleMetricData(label: 'Belum Ditangani', value: metrics['unhandled'] ?? 0, icon: Icons.pending_actions_rounded, color: const Color(0xFF7C3AED)),
        RoleMetricData(label: 'Finish Approved', value: metrics['approved_finish'] ?? 0, icon: Icons.approval_rounded, color: const Color(0xFF16A34A)),
        RoleMetricData(label: 'Total Masuk', value: metrics['total_incoming'] ?? 0, icon: Icons.confirmation_number_rounded, color: const Color(0xFF0EA5E9)),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: panelColor(context), borderRadius: BorderRadius.circular(28), border: Border.all(color: panelBorderColor(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(panelTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: titleColor(context))),
          const SizedBox(height: 14),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (user?.isUser == true || user?.isTechnicalSupport == true) ? 3 : 2,
              crossAxisSpacing: 10, 
              mainAxisSpacing: 10, 
              mainAxisExtent: 110
            ),
            itemBuilder: (context, index) => RoleMetricTile(item: items[index]),
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
  const RoleMetricData({required this.label, required this.value, required this.icon, required this.color});
}

class RoleMetricTile extends StatelessWidget {
  final RoleMetricData item;
  const RoleMetricTile({super.key, required this.item});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: softSurfaceColor(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: softBorderColor(context))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(item.icon, color: item.color, size: 18),
        Text('${item.value}', style: TextStyle(color: titleColor(context), fontSize: 20, fontWeight: FontWeight.w800, height: 1)),
        Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: mutedColor(context), fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class SnapshotPanel extends StatelessWidget {
  final int total, open, inProgress, resolved, closed;
  const SnapshotPanel({super.key, required this.total, required this.open, required this.inProgress, required this.resolved, required this.closed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: panelColor(context), borderRadius: BorderRadius.circular(32), border: Border.all(color: panelBorderColor(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ringkasan aktivitas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: titleColor(context))),
                  const SizedBox(height: 4),
                  Text('Statistik tiket helpdesk untuk periode saat ini', style: TextStyle(fontSize: 11, color: mutedColor(context), fontWeight: FontWeight.w500)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('Bulan ini', style: TextStyle(color: Color(0xFF4338CA), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ActivityCircularChart(total: total, open: open, inProgress: inProgress, resolved: resolved, closed: closed),
          const SizedBox(height: 30),
          _row(context, 'Open', open, total, AppTheme.statusColor('open')),
          _row(context, 'In Progress', inProgress, total, AppTheme.statusColor('in_progress')),
          _row(context, 'Resolved', resolved, total, AppTheme.statusColor('resolved')),
          _row(context, 'Closed', closed, total, AppTheme.statusColor('closed')),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, int val, int total, Color color) {
    final percent = total > 0 ? (val / total * 100).round() : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softBorderColor(context).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleColor(context))),
              Text('$percent%', style: TextStyle(fontSize: 10, color: mutedColor(context), fontWeight: FontWeight.w600)),
            ]),
          ),
          Text('$val', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor(context))),
        ],
      ),
    );
  }
}

class ActivityCircularChart extends StatelessWidget {
  final int total, open, inProgress, resolved, closed;
  const ActivityCircularChart({super.key, required this.total, required this.open, required this.inProgress, required this.resolved, required this.closed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 210, height: 210, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02))),
          SizedBox(width: 180, height: 180, child: CustomPaint(painter: DonutChartPainter(total: total, open: open, inProgress: inProgress, resolved: resolved, closed: closed, context: context))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$total', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: titleColor(context), letterSpacing: -1)),
            Text('Total tiket', style: TextStyle(fontSize: 12, color: mutedColor(context), fontWeight: FontWeight.w700)),
          ]),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int total, open, inProgress, resolved, closed;
  final BuildContext context;
  DonutChartPainter({required this.total, required this.open, required this.inProgress, required this.resolved, required this.closed, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    const strokeWidth = 18.0;
    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    canvas.drawCircle(center, radius - (strokeWidth / 2), Paint()..color = softSurfaceColor(context)..style = PaintingStyle.stroke..strokeWidth = strokeWidth);

    if (total == 0) return;
    double startAngle = -math.pi / 2;
    _drawArc(canvas, rect, startAngle, open, AppTheme.statusColor('open'), strokeWidth);
    startAngle += (open / total) * 2 * math.pi;
    _drawArc(canvas, rect, startAngle, inProgress, AppTheme.statusColor('in_progress'), strokeWidth);
    startAngle += (inProgress / total) * 2 * math.pi;
    _drawArc(canvas, rect, startAngle, resolved, AppTheme.statusColor('resolved'), strokeWidth);
    startAngle += (resolved / total) * 2 * math.pi;
    _drawArc(canvas, rect, startAngle, closed, AppTheme.statusColor('closed'), strokeWidth);
  }

  void _drawArc(Canvas canvas, Rect rect, double startAngle, int val, Color color, double strokeWidth) {
    if (val == 0) return;
    canvas.drawArc(rect, startAngle + 0.05, ((val / total) * 2 * math.pi) - 0.1, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QuickActionsPanel extends StatelessWidget {
  final bool canCreateTicket;
  final VoidCallback onTickets;
  final VoidCallback? onCreateTicket;
  final VoidCallback onProfile;
  final Future<void> Function() onRefresh;
  const QuickActionsPanel({super.key, required this.canCreateTicket, required this.onTickets, required this.onCreateTicket, required this.onProfile, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: panelColor(context), borderRadius: BorderRadius.circular(28), border: Border.all(color: panelBorderColor(context))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _btn(Icons.refresh_rounded, 'Refresh', onRefresh),
      _btn(Icons.list_alt_rounded, 'Tiket', onTickets),
      if (canCreateTicket) _btn(Icons.add_circle_outline_rounded, 'Baru', onCreateTicket!),
      _btn(Icons.person_rounded, 'Profil', onProfile),
    ]),
  );

  Widget _btn(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: const Color(0xFF4F46E5), size: 24),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}

class RecentTicketsPanel extends StatelessWidget {
  const RecentTicketsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final ticketCtrl = context.read<TicketProvider>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: softSurfaceColor(context), borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tiket Terbaru', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: ticketCtrl,
          builder: (context, _) {
            final recent = ticketCtrl.tickets.take(3).toList();
            if (recent.isEmpty) return const Center(child: Text('Belum ada tiket', style: TextStyle(fontSize: 12)));
            return Column(children: recent.map((t) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.confirmation_num_outlined, color: AppTheme.statusColor(t.status)),
              title: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1),
              subtitle: Text(AppTheme.statusLabel(t.status), style: TextStyle(fontSize: 11, color: AppTheme.statusColor(t.status))),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () => Get.toNamed(Routes.ticketDetail, arguments: t.id),
            )).toList());
          },
        ),
      ]),
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
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: _index,
    onDestinationSelected: (i) {
      setState(() => _index = i);
      if (i == 1) Get.toNamed(Routes.ticketList);
      if (i == 2) Get.toNamed(Routes.profile);
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Tiket'),
      NavigationDestination(icon: Icon(Icons.person_outlined), label: 'Profil'),
    ],
  );
}

Color panelColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : Colors.white;
Color panelBorderColor(BuildContext context) => Theme.of(context).colorScheme.outlineVariant;
Color softSurfaceColor(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHighest;
Color softBorderColor(BuildContext context) => Theme.of(context).colorScheme.outlineVariant;
Color titleColor(BuildContext context) => Theme.of(context).colorScheme.onSurface;
Color mutedColor(BuildContext context) => Theme.of(context).colorScheme.onSurfaceVariant;
