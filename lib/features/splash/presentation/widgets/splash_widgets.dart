import 'package:flutter/material.dart';

class SplashGlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const SplashGlowOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class SplashLogo extends StatelessWidget {
  final bool isDark;
  const SplashLogo({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        size: 72,
        color: Colors.white,
      ),
    );
  }
}
