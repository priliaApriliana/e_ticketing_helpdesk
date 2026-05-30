import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class AuthGlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const AuthGlowOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class AuthHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> chips;

  const AuthHeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Icon(icon, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: chips.map((chip) => AuthChip(label: chip)).toList(),
        ),
      ],
    );
  }
}

class AuthChip extends StatelessWidget {
  final String label;

  const AuthChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AuthSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color mutedColor;

  const AuthSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: mutedColor)),
      ],
    );
  }
}

class DemoAccountTile extends StatelessWidget {
  final String role;
  final String email;
  final AuthProvider ctrl;
  final Color textColor;
  final Color mutedColor;

  const DemoAccountTile({
    super.key,
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

class RegisterBulletLine extends StatelessWidget {
  final String text;

  const RegisterBulletLine({super.key, required this.text});

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
