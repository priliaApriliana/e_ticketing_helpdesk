import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:e_ticketing_helpdesk/features/profile/data/models/user_model.dart';
import 'package:e_ticketing_helpdesk/core/constants/api_constants.dart';

class AuthService extends GetxService {
  final _box = GetStorage();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  final RxList<UserModel> technicalSupportUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    if (isLoggedIn) {
      fetchTechnicalSupports();
    }
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

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_box.read('token')}',
      };

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint('Error getAllUsers: $e');
    }
    return [];
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/role'),
        headers: _headers,
        body: jsonEncode({'role': newRole}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updateUserRole: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleteUser: $e');
      return false;
    }
  }

  Future<void> fetchTechnicalSupports() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users?role=technical_support'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        technicalSupportUsers.value = data.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchTechnicalSupports: $e');
    }
  }

  bool isTechnicalSupportId(String userId) {
    return technicalSupportUsers.any((u) => u.id == userId);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(data['user']);
        currentUser.value = userModel;
        _box.write('user', userModel.toJson());
        _box.write('token', data['token']);
        
        await fetchTechnicalSupports();
        
        return {'success': true, 'user': userModel};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      return {'success': (response.statusCode == 201 || response.statusCode == 200), 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/change-password'),
        headers: _headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    technicalSupportUsers.clear();
    _box.remove('user');
    _box.remove('token');
  }
}
