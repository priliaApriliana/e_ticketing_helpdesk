import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/features/notification/presentation/providers/notification_provider.dart';
import '../../../../core/controllers/theme_controller.dart';

class ProfileBackdrop extends StatelessWidget {
  const ProfileBackdrop({super.key});

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
            child: ProfileOrb(
              size: 200,
              colors: [
                const Color(0xFF7C3AED).withValues(alpha: 0.22),
                const Color(0xFF2563EB).withValues(alpha: 0.05),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: -100,
            child: ProfileOrb(
              size: 180,
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

class ProfileOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const ProfileOrb({super.key, required this.size, required this.colors});

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

class ProfileTopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileTopBar({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: ProfileUIHelpers.softSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.person_rounded,
            color: ProfileUIHelpers.titleColor(context),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ProfileUIHelpers.titleColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Atur akun dan preferensi tampilan',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ProfileUIHelpers.mutedColor(context)),
              ),
            ],
          ),
        ),
        ProfileActionIconButton(icon: Icons.logout_rounded, onTap: onLogout),
      ],
    );
  }
}

class ProfileActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProfileActionIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileUIHelpers.softSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: ProfileUIHelpers.titleColor(context), size: 22),
        ),
      ),
    );
  }
}

class HeroProfileCard extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final String roleLabel;

  const HeroProfileCard({
    super.key,
    required this.initials,
    required this.name,
    required this.email,
    required this.roleLabel,
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
            top: -20,
            right: -10,
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                  roleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tampilan profil disatukan dengan bahasa visual dashboard agar terasa lebih premium.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountSummaryCard extends StatelessWidget {
  final dynamic user;

  const AccountSummaryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ProfileUIHelpers.panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ProfileUIHelpers.panelBorderColor(context)),
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
            'Informasi akun',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: ProfileUIHelpers.titleColor(context),
            ),
          ),
          const SizedBox(height: 14),
          ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'Nama',
            value: user?.name ?? '-',
          ),
          const SizedBox(height: 10),
          ProfileInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? '-',
          ),
          const SizedBox(height: 10),
          ProfileInfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Role',
            value: ProfileUIHelpers.formatRole(user?.role ?? ''),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProfileUIHelpers.softSurfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfileUIHelpers.softBorderColor(context)),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: ProfileUIHelpers.mutedColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: ProfileUIHelpers.titleColor(context),
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

class ProfileMenuPanel extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  const ProfileMenuPanel({
    super.key,
    required this.isAdmin,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onNotifications,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ProfileUIHelpers.panelColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ProfileUIHelpers.panelBorderColor(context)),
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
            'Pengaturan cepat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: ProfileUIHelpers.titleColor(context),
            ),
          ),
          const SizedBox(height: 14),
          ProfileMenuTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profil',
            subtitle: 'Update nama dan data akun',
            onTap: onEditProfile,
          ),
          const SizedBox(height: 10),
          ProfileMenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun',
            onTap: onChangePassword,
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final unread = context.watch<NotificationProvider>().unreadCount;
              return ProfileMenuTile(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi',
                subtitle: 'Atur preferensi notifikasi',
                badgeCount: unread,
                onTap: onNotifications,
              );
            },
          ),
          const SizedBox(height: 10),
          ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Tema dan preferensi aplikasi',
            onTap: () => Get.toNamed(Routes.settings),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 10),
            ProfileMenuTile(
              icon: Icons.group_outlined,
              title: 'Manajemen Pengguna',
              subtitle: 'Kelola role dan data pengguna',
              onTap: () => Get.toNamed(Routes.userManagement),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF4338CA);
    return Material(
      color: ProfileUIHelpers.softSurfaceColor(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ProfileUIHelpers.softBorderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ProfileUIHelpers.titleColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ProfileUIHelpers.mutedColor(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right_rounded, color: ProfileUIHelpers.mutedColor(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileBottomNav extends StatelessWidget {
  final int selectedIndex;

  const ProfileBottomNav({super.key, required this.selectedIndex});

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

class ProfileUIHelpers {
  static String formatRole(String role) {
    if (role.isEmpty) return 'Pengguna';
    return role[0].toUpperCase() + role.substring(1);
  }

  static Color panelColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF111827).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.90);
  }

  static Color panelBorderColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? scheme.outlineVariant.withValues(alpha: 0.72)
        : scheme.outlineVariant.withValues(alpha: 0.55);
  }

  static Color softSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  static Color softBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  static Color titleColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color mutedColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}
