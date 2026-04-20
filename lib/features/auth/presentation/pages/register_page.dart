import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final surfaceColor = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.94) : Colors.white.withValues(alpha: 0.96);
    final borderColor = isDark ? const Color(0xFF334155).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.88);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0B1220), Color(0xFF1E1B4B), Color(0xFF312E81)]
                : const [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF4F46E5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -30,
                child: AuthGlowOrb(color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.16), size: 170),
              ),
              Positioned(
                bottom: -80,
                left: -40,
                child: AuthGlowOrb(color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.08), size: 190),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeroSection(
                                title: 'Buat Akun Baru',
                                subtitle: 'Isi data di bawah untuk mendaftar',
                                icon: Icons.person_add_alt_1_rounded,
                                chips: const [
                                  'Biodata',
                                  'Akses aman',
                                  'Siap dipakai',
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
                                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.10),
                                      blurRadius: 24,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: ctrl.registerFormKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AuthSectionTitle(
                                        title: 'Detail akun',
                                        subtitle: 'Lengkapi data untuk mulai menggunakan aplikasi',
                                        titleColor: titleColor,
                                        mutedColor: mutedColor,
                                      ),
                                      const SizedBox(height: 18),
                                      TextFormField(
                                        controller: ctrl.nameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Nama Lengkap',
                                          prefixIcon: Icon(Icons.person_outlined),
                                        ),
                                        validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: ctrl.emailCtrl,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(Icons.email_outlined),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Email wajib diisi';
                                          if (!v.isEmail) return 'Format email tidak valid';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        'Keamanan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: titleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gunakan password yang mudah diingat tetapi kuat.',
                                        style: TextStyle(color: mutedColor),
                                      ),
                                      const SizedBox(height: 14),
                                      Obx(
                                        () => TextFormField(
                                          controller: ctrl.passwordCtrl,
                                          obscureText: ctrl.obscurePassword.value,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: const Icon(Icons.lock_outlined),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl.obscurePassword.value
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () => ctrl.obscurePassword.toggle(),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Password wajib diisi';
                                            if (v.length < 6) return 'Minimal 6 karakter';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Obx(
                                        () => TextFormField(
                                          controller: ctrl.confirmPasswordCtrl,
                                          obscureText: ctrl.obscureConfirmPassword.value,
                                          decoration: InputDecoration(
                                            labelText: 'Konfirmasi Password',
                                            prefixIcon: const Icon(Icons.lock_outlined),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                ctrl.obscureConfirmPassword.value
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () => ctrl.obscureConfirmPassword.toggle(),
                                            ),
                                          ),
                                          validator: (v) => v == null || v.isEmpty ? 'Konfirmasi password wajib diisi' : null,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Obx(
                                        () => SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: ctrl.isLoading.value ? null : ctrl.register,
                                            child: ctrl.isLoading.value
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Text('Daftar'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Sudah punya akun?', style: TextStyle(color: mutedColor)),
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Login'),
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
                                  color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Syarat singkat',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _BulletLine(text: 'Nama dan email harus valid.'),
                                    _BulletLine(text: 'Password minimal 6 karakter.'),
                                    _BulletLine(text: 'Konfirmasi password harus sama.'),
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

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



