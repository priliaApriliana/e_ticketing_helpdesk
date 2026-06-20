import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Reactive themeMode
  final themeMode = Rx<ThemeMode>(ThemeMode.light);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    // Ambil data dari storage, default ke false jika kosong
    bool isDark = _box.read(_key) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _box.write(_key, isDark);
    
    // Memberitahu GetX untuk mengganti tema aplikasi secara instan
    Get.changeThemeMode(themeMode.value);
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
}
