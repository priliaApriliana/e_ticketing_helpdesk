import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = Get.find<AuthService>();

  UserModel? get currentUser => _authService.currentUser.value;

  Future<Map<String, dynamic>> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) {
    return _authService.register(name, email, password);
  }

  Future<void> logout() {
    return _authService.logout();
  }
}





