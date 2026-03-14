// lib/screens/role_select_screen.dart
import 'package:flutter/material.dart';
import 'package:inklink/config/app_brand.dart';
import '../app_routes.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppBrand.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _tile(
                context,
                icon: Icons.brush,
                title: 'Tattoo Artist',
                subtitle: 'Build your profile + portfolio',
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.profileHub,
                ),
              ),
              const Spacer(),
              const Text(
                'Artist-only mode right now.\nClient + Owner coming back later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
