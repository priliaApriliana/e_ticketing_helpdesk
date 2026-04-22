import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import '../providers/ticket_provider.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TicketProvider>();
    final authService = context.read<AuthService>();
    final user = authService.currentUser.value;
    final tickets = ctrl.tickets;
    final total = tickets.length;
    final open = tickets.where((ticket) => ticket.status == 'open').length;
    final inProgress = tickets
        .where((ticket) => ticket.status == 'in_progress')
        .length;
    final resolved = tickets.where((ticket) => ticket.status == 'resolved').length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: ctrl.loadTickets,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  _TopBar(onRefresh: ctrl.loadTickets),
                  const SizedBox(height: 18),
                  _HeroPanel(
                    userName: user?.name ?? 'Pengguna',
                    totalTickets: total,
                    openTickets: open,
                    inProgressTickets: inProgress,
                    resolvedTickets: resolved,
                  ),
                  const SizedBox(height: 16),
                  _FilterPanel(controller: ctrl),
                  const SizedBox(height: 16),
                  _TicketFeed(controller: ctrl),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (user?.isUser == true)
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.ticketCreate),
              icon: Icon(Icons.add_rounded),
              label: const Text('Buat Tiket'),
            )
          : null,
      bottomNavigationBar: _BottomNav(selectedIndex: 1),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

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
            child: _Orb(
              size: 200,
              colors: [
                const Color(0xFF7C3AED).withValues(alpha: 0.22),
                const Color(0xFF2563EB).withValues(alpha: 0.05),
              ],
            ),
          ),
          Positioned(
            top: 180,
            left: -90,
            child: _Orb(
              size: 170,
              colors: [
                const Color(0xFF22C55E).withValues(alpha: 0.12),
                const Color(0xFF38BDF8).withValues(alpha: 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Orb({required this.size, required this.colors});

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
  final Future<void> Function() onRefresh;

  const _TopBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _softSurfaceColor(context),
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
            icon: Icon(
              Icons.list_alt_rounded,
              color: _titleColor(context),
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Tiket',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _titleColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pantau semua tiket tanpa tampilan yang kaku',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _mutedColor(context)),
              ),
            ],
          ),
        ),
        _ActionIconButton(icon: Icons.refresh_rounded, onTap: onRefresh),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Future<void> Function() onTap;

  const _ActionIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String userName;
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int resolvedTickets;

  const _HeroPanel({
    required this.userName,
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
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
                ),
                child: Text(
                  'Halo, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ticket Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ringkasan tiket dibuat lebih padat, modern, dan mudah dipindai.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfoCard(
                      label: 'Total',
                      value: totalTickets.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniInfoCard(
                      label: 'Open',
                      value: openTickets.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniInfoCard(
                      label: 'Progress',
                      value: inProgressTickets.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MiniProgressRow(
                label: 'Resolved',
                value: resolvedTickets,
                total: totalTickets,
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

  const _MiniInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
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
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _MiniProgressRow({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : value / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final TicketProvider controller;

  const _FilterPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = const [
      ('all', 'Semua'),
      ('open', 'Open'),
      ('in_progress', 'In Progress'),
      ('resolved', 'Resolved'),
      ('closed', 'Closed'),
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
            'Filter status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih status untuk menyaring tiket dengan cepat',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => Row(
                children: [
                  for (final filter in filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter.$2),
                        selected: controller.selectedFilter.value == filter.$1,
                        onSelected: (_) => controller.setFilter(filter.$1),
                        selectedColor: const Color(
                          0xFF4F46E5,
                        ).withValues(alpha: 0.14),
                        labelStyle: TextStyle(
                          color: controller.selectedFilter.value == filter.$1
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketFeed extends StatelessWidget {
  final TicketProvider controller;

  const _TicketFeed({required this.controller});

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
                child: Text(
                  'Daftar tiket',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _titleColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.loadTickets,
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.isLoading.value) {
                return const _LoadingTickets();
              }
              if (controller.tickets.isEmpty) {
                return const _EmptyState();
              }
              return Column(
                children: [
                  for (var i = 0; i < controller.tickets.length; i++) ...[
                    _TicketCard(ticket: controller.tickets[i]),
                    if (i != controller.tickets.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

class _LoadingTickets extends StatelessWidget {
  const _LoadingTickets();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: _softSurfaceColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _softBorderColor(context)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _softSurfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorderColor(context)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 44, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            'Tidak ada tiket',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: _titleColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saat data masuk, daftar akan muncul di sini.',
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

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(ticket.status);
    final priorityColor = AppTheme.priorityColor(ticket.priority);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Get.toNamed(Routes.ticketDetail, arguments: ticket.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _softSurfaceColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _softBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ticket.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.45,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Pill(
                    text: _cap(ticket.priority),
                    background: priorityColor.withValues(alpha: 0.10),
                    foreground: priorityColor,
                  ),
                  _MetaChip(
                    icon: Icons.folder_outlined,
                    label: ticket.category,
                  ),
                  _MetaChip(
                    icon: Icons.access_time_rounded,
                    label: timeago.format(ticket.createdAt, locale: 'id'),
                  ),
                  if (ticket.commentCount > 0)
                    _MetaChip(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${ticket.commentCount} komentar',
                    ),
                ],
              ),
              if (ticket.assignedToName != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Ditangani: ${ticket.assignedToName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF475569)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 118),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.statusColor(status).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          AppTheme.statusLabel(status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.statusColor(status),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;

  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        if (index == 0) Get.toNamed(Routes.dashboard);
        if (index == 1) Get.toNamed(Routes.ticketList);
        if (index == 2) Get.toNamed(Routes.profile);
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

String _cap(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
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











