import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import 'package:e_ticketing_helpdesk/features/auth/presentation/widgets/password_action_dialog.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topSpacing = MediaQuery.sizeOf(context).height < 700 ? 14.0 : 24.0;

    final titleColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final surfaceColor = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.97);
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: topSpacing),
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
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(24),
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
                                      AnimatedBuilder(animation: ctrl, builder: (context, _) => TextFormField(
                                          controller: ctrl.passwordCtrl,
                                          obscureText:
                                              ctrl.obscurePassword,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: const Icon(
                                              Icons.lock_outlined,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl.obscurePassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () =>
                                                  ctrl.toggleObscurePassword(),
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
                                          onPressed: () =>
                                              showPasswordActionDialog(
                                                title: 'Reset Password',
                                                description:
                                                    'Masukkan email akun dan password baru untuk mengganti password akun demo Anda.',
                                                submitLabel: 'Reset Password',
                                                showEmailField: true,
                                                requireCurrentPassword: false,
                                                onSubmit: (email, _, newPassword) =>
                                                    context
                                                        .read<AuthProvider>()
                                                        .resetPassword(
                                                          email,
                                                          newPassword,
                                                        ),
                                              ),
                                          child: const Text('Lupa Password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      AnimatedBuilder(animation: ctrl, builder: (context, _) => SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed: ctrl.isLoading
                                                ? null
                                                : ctrl.login,
                                            child: ctrl.isLoading
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
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 4,
                                          runSpacing: 0,
                                          children: [
                                            Text(
                                              'Belum punya akun?',
                                              style: TextStyle(
                                                color: mutedColor,
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                              ),
                                              onPressed: () =>
                                                  Get.toNamed(Routes.register),
                                              child: const Text(
                                                'Daftar Sekarang',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: mutedColor.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Text(
                                              'atau',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: mutedColor,
                                                fontSize: 12,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: mutedColor.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Pilih akun demo di bawah untuk auto-fill email & password.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: mutedColor,
                                            fontSize: 12,
                                          ),
                                        ),
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
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap salah satu akun untuk login lebih cepat',
                                      style: TextStyle(
                                        color: mutedColor,
                                        fontSize: 12,
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
    final roleIcon = switch (role) {
      'Admin' => Icons.admin_panel_settings_outlined,
      'Helpdesk' => Icons.support_agent_outlined,
      _ => Icons.person_outline,
    };

    return InkWell(
      onTap: () {
        ctrl.emailCtrl.text = email;
        ctrl.passwordCtrl.text = '123456';
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.68),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(roleIcon, size: 18, color: const Color(0xFF5B21B6)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: mutedColor),
          ],
        ),
      ),
    );
  }
}





