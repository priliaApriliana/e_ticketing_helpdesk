import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  final _authService = Get.find<AuthService>();

  final users = <UserModel>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;

  void onInit() {
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    notifyListeners();
    try {
      users.value = await _authService.getAllUsers();
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    isUpdating.value = true;
    notifyListeners();
    try {
      final success = await _authService.updateUserRole(userId, newRole);
      if (success) {
        await loadUsers();
        Get.snackbar('Berhasil', 'Role pengguna telah diperbarui');
      } else {
        Get.snackbar('Gagal', 'Gagal memperbarui role pengguna');
      }
    } finally {
      isUpdating.value = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    isUpdating.value = true;
    notifyListeners();
    try {
      final success = await _authService.deleteUser(userId);
      if (success) {
        await loadUsers();
        Get.snackbar('Berhasil', 'Pengguna telah dihapus');
      } else {
        Get.snackbar('Gagal', 'Gagal menghapus pengguna');
      }
    } finally {
      isUpdating.value = false;
      notifyListeners();
    }
  }
}
