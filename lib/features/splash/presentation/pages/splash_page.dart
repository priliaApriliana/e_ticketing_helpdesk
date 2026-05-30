import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/routes/app_routes.dart';
import '../widgets/splash_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _navigate());
  }

  Future<void> _navigate() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      if (!Get.isRegistered<AuthService>()) {
        Get.put(AuthService(), permanent: true);
      }

      final authService = Get.find<AuthService>();
      if (authService.isLoggedIn) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (error) {
      debugPrint('Error in splash navigation: $error');
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF2E1065), Color(0xFF4C1D95), Color(0xFF1E1B4B)]
          : const [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF4F46E5)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: SplashGlowOrb(color: Colors.white.withValues(alpha: 0.16), size: 180),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: SplashGlowOrb(color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06), size: 160),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SplashLogo(isDark: isDark),
                    const SizedBox(height: 24),
                    const Text(
                      'E-Ticketing Helpdesk',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Universitas Airlangga',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 56),
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          minHeight: 4,
                          color: Colors.white,
                          backgroundColor: Color(0x33FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
