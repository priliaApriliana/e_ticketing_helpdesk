import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../providers/user_management_provider.dart';
import '../../data/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.loadUsers,
          ),
        ],
      ),
      body: provider.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : provider.users.isEmpty
              ? const Center(child: Text('Tidak ada pengguna ditemukan'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return UserCard(user: user, provider: provider);
                  },
                ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;
  final UserManagementProvider provider;

  const UserCard({super.key, required this.user, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _getRoleColor(user.role).withOpacity(0.5)),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirm(context);
                } else {
                  provider.changeUserRole(user.id, value);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'user', child: Text('Set sebagai User')),
                const PopupMenuItem(value: 'helpdesk', child: Text('Set sebagai Helpdesk')),
                const PopupMenuItem(value: 'technical_support', child: Text('Set sebagai Teknisi')),
                const PopupMenuItem(value: 'admin', child: Text('Set sebagai Admin')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus Pengguna', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'helpdesk': return Colors.blue;
      case 'technical_support': return Colors.orange;
      default: return Colors.green;
    }
  }

  void _showDeleteConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              provider.deleteUser(user.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
