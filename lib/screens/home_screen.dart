import 'package:flutter/material.dart';
import 'package:inklink/config/app_brand.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext pathCtx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppBrand.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _cardButton(
              pathCtx,
              title: 'Role Select',
              subtitle: 'Pick Artist / Owner / Client',
              route: '/roleSelect',
              icon: Icons.badge,
            ),
            const SizedBox(height: 12),
            _cardButton(
              pathCtx,
              title: 'Search',
              subtitle: 'Discover artists/owners/clients (seed data)',
              route: '/searchArtist',
              icon: Icons.search,
            ),
            const SizedBox(height: 12),
            _cardButton(
              pathCtx,
              title: 'Artist Setup',
              subtitle: 'Create your artist profile',
              route: '/artistFlow',
              icon: Icons.brush,
            ),
            const SizedBox(height: 12),
            _cardButton(
              pathCtx,
              title: 'Owner Setup',
              subtitle: 'Host talent + list opportunities',
              route: '/ownerFlow',
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
            _cardButton(
              pathCtx,
              title: 'Portfolio Builder',
              subtitle: 'Add portfolio images + captions (local stub)',
              route: '/portfolioBuilder',
              icon: Icons.photo_library,
            ),
            const SizedBox(height: 12),
            _cardButton(
              pathCtx,
              title: 'Client Mode',
              subtitle: 'Client flow (coming soon)',
              route: '/clientFlow',
              icon: Icons.people,
              enabled: false, // flip to true when ready
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardButton(
    BuildContext pathCtx, {
    required String title,
    required String subtitle,
    required String route,
    required IconData icon,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? () => Navigator.pushNamed(pathCtx, route) : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
