import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';

class AuthService extends GetxService {
  final _box = GetStorage();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Budi Admin',
      'email': 'admin@test.com',
      'password': '123456',
      'role': 'admin',
      'avatar': null,
    },
    {
      'id': '2',
      'name': 'Siti Helpdesk',
      'email': 'helpdesk@test.com',
      'password': '123456',
      'role': 'helpdesk',
      'avatar': null,
    },
    {
      'id': '4',
      'name': 'Rizky Technical Support',
      'email': 'ts1@test.com',
      'password': '123456',
      'role': 'technical_support',
      'avatar': null,
    },
    {
      'id': '5',
      'name': 'Nina Technical Support',
      'email': 'ts2@test.com',
      'password': '123456',
      'role': 'technical_support',
      'avatar': null,
    },
    {
      'id': '3',
      'name': 'Andi User',
      'email': 'user@test.com',
      'password': '123456',
      'role': 'user',
      'avatar': null,
    },
        {
      'id': '6',
      'name': 'Putri User',
      'email': 'putri@test.com',
      'password': '123456',
      'role': 'user',
      'avatar': null,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    final userData = _box.read('user');
    if (userData != null) {
      currentUser.value = UserModel.fromJson(
        Map<String, dynamic>.from(userData),
      );
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  List<UserModel> get allUsers {
    return _mockUsers
        .map((user) => UserModel.fromJson(Map<String, dynamic>.from(user)))
        .toList();
  }

  List<UserModel> get technicalSupportUsers {
    return usersByRole('technical_support');
  }

  List<UserModel> get assignableUsers => technicalSupportUsers;

  List<UserModel> usersByRole(String role) {
    return allUsers.where((user) => user.role == role).toList();
  }

  Set<String> userIdsByRole(String role) {
    return usersByRole(role).map((user) => user.id).toSet();
  }

  Set<String> get adminIds => userIdsByRole('admin');
  Set<String> get helpdeskIds => userIdsByRole('helpdesk');
  Set<String> get technicalSupportIds => userIdsByRole('technical_support');

  UserModel? findUserById(String id) {
    final user = _mockUsers.firstWhereOrNull((item) => item['id'] == id);
    if (user == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(user));
  }

  bool isTechnicalSupportId(String userId) {
    return _mockUsers.any(
      (user) => user['id'] == userId && user['role'] == 'technical_support',
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final user = _mockUsers.firstWhereOrNull(
      (u) => u['email'] == email && u['password'] == password,
    );

    if (user == null) {
      return {'success': false, 'message': 'Email atau password salah'};
    }

    final userModel = UserModel.fromJson(user);
    currentUser.value = userModel;
    _box.write('user', userModel.toJson());
    _box.write('token', 'mock_token_${user['id']}');

    return {'success': true, 'user': userModel};
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final exists = _mockUsers.any((u) => u['email'] == email);
    if (exists) {
      return {'success': false, 'message': 'Email sudah terdaftar'};
    }

    _mockUsers.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'password': password,
      'role': 'user',
      'avatar': null,
    });

    return {'success': true, 'message': 'Registrasi berhasil, silakan login'};
  }

  Future<void> logout() async {
    currentUser.value = null;
    _box.remove('user');
    _box.remove('token');
  }
}



