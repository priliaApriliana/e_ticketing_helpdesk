import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/widgets/password_action_dialog.dart';

import '../providers/profile_provider.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends GetView<ProfileProvider> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final initials = _getInitials(user?.name ?? '?');
    final roleLabel = ProfileUIHelpers.formatRole(user?.role ?? '');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const ProfileBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                ProfileTopBar(onLogout: _showLogoutDialog),
                const SizedBox(height: 18),
                HeroProfileCard(
                  initials: initials,
                  name: user?.name ?? '',
                  email: user?.email ?? '',
                  roleLabel: roleLabel,
                ),
                const SizedBox(height: 16),
                AccountSummaryCard(user: user),
                const SizedBox(height: 16),
                ProfileMenuPanel(
                  isAdmin: user?.isAdmin ?? false, // Tambahkan parameter ini
                  onEditProfile: () => Get.snackbar(
                    'Info',
                    'Fitur edit profil masih dalam pengembangan',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                  onChangePassword: () => showPasswordActionDialog(
                    title: 'Ubah Password',
                    description:
                        'Masukkan password lama dan password baru untuk akun yang sedang aktif.',
                    submitLabel: 'Simpan Password Baru',
                    email: user?.email,
                    showEmailField: false,
                    requireCurrentPassword: true,
                    onSubmit: (_, currentPassword, newPassword) =>
                        controller.changePassword(currentPassword, newPassword),
                  ),
                  onNotifications: () => Get.toNamed(Routes.notifications),
                  onLogout: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ProfileBottomNav(selectedIndex: 2),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: controller.logout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
