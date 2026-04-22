import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';

class ProfileRepository {
  final AuthService _authService = Get.find<AuthService>();

  UserModel? get currentUser => _authService.currentUser.value;

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) {
    return _authService.changePassword(currentPassword, newPassword);
  }

  Future<void> logout() {
    return _authService.logout();
  }
}




