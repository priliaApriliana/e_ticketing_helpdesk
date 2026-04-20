import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final surfaceColor = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);
    final borderColor = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.88);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B1220),
                    Color(0xFF1E1B4B),
                    Color(0xFF312E81),
                  ]
                : const [
                    Color(0xFF7C3AED),
                    Color(0xFF6D28D9),
                    Color(0xFF4F46E5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -30,
                child: AuthGlowOrb(
                  color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.16),
                  size: 170,
                ),
              ),
              Positioned(
                bottom: -80,
                left: -40,
                child: AuthGlowOrb(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.08),
                  size: 190,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeroSection(
                                title: 'Selamat Datang!',
                                subtitle:
                                    'Login ke akun Anda untuk melanjutkan',
                                icon: Icons.support_agent_rounded,
                                chips: const [
                                  'Akses cepat',
                                  'Status tiket',
                                  'Riwayat rapi',
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.18 : 0.10,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: ctrl.loginFormKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AuthSectionTitle(
                                        title: 'Masuk ke aplikasi',
                                        subtitle:
                                            'Gunakan akun demo atau akun Anda sendiri',
                                        titleColor: titleColor,
                                        mutedColor: mutedColor,
                                      ),
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        controller: ctrl.emailCtrl,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                          hintText: 'contoh@email.com',
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Email wajib diisi';
                                          }
                                          if (!v.isEmail) {
                                            return 'Format email tidak valid';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      Obx(
                                        () => TextFormField(
                                          controller: ctrl.passwordCtrl,
                                          obscureText:
                                              ctrl.obscurePassword.value,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: const Icon(
                                              Icons.lock_outlined,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl.obscurePassword.value
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () =>
                                                  ctrl.obscurePassword.toggle(),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Password wajib diisi';
                                            }
                                            if (v.length < 6) {
                                              return 'Password minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => Get.snackbar(
                                            'Info',
                                            'Hubungi admin untuk reset password',
                                            snackPosition: SnackPosition.BOTTOM,
                                          ),
                                          child: const Text('Lupa Password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Obx(
                                        () => SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: ctrl.isLoading.value
                                                ? null
                                                : ctrl.login,
                                            child: ctrl.isLoading.value
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Text('Login'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 4,
                                        runSpacing: 0,
                                        children: [
                                          Text(
                                            'Belum punya akun?',
                                            style: TextStyle(color: mutedColor),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Get.toNamed(Routes.register),
                                            child: const Text(
                                              'Daftar Sekarang',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF111827)
                                      : const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Akun Demo',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    _DemoAccountTile(
                                      role: 'Admin',
                                      email: 'admin@test.com',
                                      ctrl: ctrl,
                                      textColor: titleColor,
                                      mutedColor: mutedColor,
                                    ),
                                    _DemoAccountTile(
                                      role: 'Helpdesk',
                                      email: 'helpdesk@test.com',
                                      ctrl: ctrl,
                                      textColor: titleColor,
                                      mutedColor: mutedColor,
                                    ),
                                    _DemoAccountTile(
                                      role: 'User',
                                      email: 'user@test.com',
                                      ctrl: ctrl,
                                      textColor: titleColor,
                                      mutedColor: mutedColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  final String role;
  final String email;
  final AuthProvider ctrl;
  final Color textColor;
  final Color mutedColor;

  const _DemoAccountTile({
    required this.role,
    required this.email,
    required this.ctrl,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ctrl.emailCtrl.text = email;
        ctrl.passwordCtrl.text = '123456';
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                email,
                style: TextStyle(fontSize: 12, color: mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




