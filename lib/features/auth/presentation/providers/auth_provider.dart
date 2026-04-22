import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_ticketing_helpdesk/features/auth/data/repositories/auth_repository.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading = true;
    notifyListeners();
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
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      Get.snackbar(
        'Error',
        'Password tidak cocok',
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading = true;
    notifyListeners();
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
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed(Routes.login);
      } else {
        Get.snackbar(
          'Gagal',
          result['message'],
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) {
    return _authRepository.resetPassword(email, newPassword);
  }

  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    confirmPasswordCtrl.dispose();
  }
}
