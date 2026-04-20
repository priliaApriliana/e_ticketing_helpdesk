import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/features/profile/data/repositories/profile_repository.dart';

class ProfileProvider extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

  UserModel? get user => _profileRepository.currentUser;

  Future<void> logout() async {
    await _profileRepository.logout();
    Get.offAllNamed(Routes.login);
  }
}



