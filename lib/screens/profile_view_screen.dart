import 'package:flutter/material.dart';
import '../models/ink_profile.dart';
import '../repositories/profile_repository.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final _repo = ProfileRepository();
  final _scroll = ScrollController();
  final _travelKey = GlobalKey();

  Map<String, dynamic> _args(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) return {'id': raw};
    return {};
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToTravel() {
    final ctx = _travelKey.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  Widget _avatar(InkProfile p) {
    final url = (p.avatarUrl).trim();
    final hasUrl = url.startsWith('http://') || url.startsWith('https://');

    if (hasUrl) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(url),
      );
    }

    // Fallback: first letter
    final initial = p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 28,
      child: Text(initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _args(context);
    final id = (args['id'] ?? '').toString();
    final focus = (args['focus'] ?? '').toString();
    final focusCity = (args['city'] ?? '').toString().trim().toLowerCase();

    final InkProfile? p = _repo.getById(id);

    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Profile not found')),
      );
    }

    if (focus == 'travel') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTravel());
    }

    bool matchCity(String city) {
      if (focusCity.isEmpty) return false;
      return city.toLowerCase().contains(focusCity);
    }

    return Scaffold(
      appBar: AppBar(title: Text(p.displayName)),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _avatar(p),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.displayName, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('${p.city} • ${p.role.name}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (p.bio.trim().isNotEmpty) ...[
            Text(p.bio),
            const SizedBox(height: 16),
          ],

          if (p.styles.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.styles.map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 22),
          ],

          if (p.travel.isNotEmpty) ...[
            Container(
              key: _travelKey,
              child: Text('Travel', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            ...p.travel.map((t) {
              final isMatch = matchCity(t.city);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                  color: isMatch ? Colors.deepPurple.withOpacity(0.15) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.city,
                            style: TextStyle(
                              fontWeight: isMatch ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${t.note} • ${t.start.month}/${t.start.day} → ${t.end.month}/${t.end.day}',
                          ),
                        ],
                      ),
                    ),
                    if (isMatch) const Icon(Icons.my_location, size: 18),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
          ],

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messaging coming next')),
              );
            },
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }
}
