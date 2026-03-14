import 'package:flutter/foundation.dart';
import 'package:inklink/data/seed_profiles.dart';
import 'package:inklink/models/ink_profile.dart';
import 'package:inklink/models/ink_role.dart';

class ProfileRepository {
  List<InkProfile> getAll() => seedProfiles;

  InkProfile? getById(String id) {
    try {
      return seedProfiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // 👇 The ONLY source of truth for "who is allowed to appear"
  Set<InkRole> allowedRolesForViewer(InkRole viewerRole) {
    switch (viewerRole) {
      case InkRole.client:
        // Clients search for creators only
        return {InkRole.artist, InkRole.owner};

      case InkRole.owner:
      case InkRole.artist:
        // Creators can see everyone (adjust if you want)
        return {InkRole.artist, InkRole.owner, InkRole.client};
    }
  }

  List<InkProfile> search({
    required InkRole viewerRole,
    String query = '',
    String? city,
    InkRole? role,
    Set<String> styles = const {},
    Set<InkRole>? allowedRolesOverride,
  }) {
    final allowedRoles = allowedRolesOverride ?? allowedRolesForViewer(viewerRole);

    debugPrint(
      'REPO SEARCH HIT | viewerRole=$viewerRole | allowedRoles=$allowedRoles',
    );

    final q = query.trim().toLowerCase();
    final c = (city ?? '').trim().toLowerCase();

    bool cityStrongMatch(InkProfile p) {
      if (c.isEmpty) return false;
      final base = p.city.toLowerCase();
      final inBase = base.contains(c);
      final inTravel = p.travel.any((t) => t.city.toLowerCase().contains(c));
      return inBase || inTravel;
    }

    int score(InkProfile p) {
      int s = 0;

      if (c.isNotEmpty) {
        if (p.city.toLowerCase().contains(c)) s += 100;
        if (p.travel.any((t) => t.city.toLowerCase().contains(c))) s += 80;
      }

      if (q.isNotEmpty) {
        if (p.displayName.toLowerCase().contains(q)) s += 30;
        if ((p.shopName ?? '').toLowerCase().contains(q)) s += 25;
        if (p.styles.any((x) => x.toLowerCase().contains(q))) s += 20;
        if (p.bio.toLowerCase().contains(q)) s += 10;
      }

      if (p.travel.isNotEmpty) s += 2;

      return s;
    }

    final filtered = seedProfiles.where((p) {
      // 🔒 Hard allowlist first: if your role isn't allowed, you're out.
      if (!allowedRoles.contains(p.role)) return false;

      // If user picked a specific role filter
      if (role != null && p.role != role) return false;

      // Use existing model helpers
      if (!p.matchesQuery(query)) return false;
      if (!p.matchesCity(city)) return false;
      if (!p.matchesStyles(styles)) return false;

      return true;
    }).toList();

    filtered.sort((a, b) {
      final aStrong = cityStrongMatch(a);
      final bStrong = cityStrongMatch(b);

      if (aStrong != bStrong) return aStrong ? -1 : 1;

      final sb = score(b).compareTo(score(a));
      if (sb != 0) return sb;

      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return filtered;
  }
}
