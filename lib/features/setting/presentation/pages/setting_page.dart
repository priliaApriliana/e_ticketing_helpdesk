import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/theme_controller.dart';

class SettingScreen extends GetView<ThemeController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Obx(() => ListTile(
              leading: Icon(
                controller.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Mode Gelap'),
              subtitle: Text(
                controller.isDarkMode ? 'Tampilan gelap diaktifkan' : 'Tampilan terang diaktifkan'
              ),
              trailing: Switch(
                value: controller.isDarkMode,
                onChanged: (val) => controller.toggleTheme(val),
              ),
            )),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Informasi Aplikasi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Versi'),
            trailing: Text('1.0.0 (UAS Project)'),
          ),
        ],
      ),
    );
  }
}
