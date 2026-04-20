import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_ticketing_helpdesk/features/auth/data/repositories/auth_repository.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';

class AuthProvider extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final result = await _authRepository.login(
        emailCtrl.text.trim(),
        passwordCtrl.text,
      );
      if (result['success']) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.snackbar(
          'Login Gagal',
          result['message'],
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      Get.snackbar(
        'Error',
        'Password tidak cocok',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    try {
      final result = await _authRepository.register(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passwordCtrl.text,
      );
      if (result['success']) {
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed(Routes.login);
      } else {
        Get.snackbar(
          'Gagal',
          result['message'],
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}



