import 'package:inklink/models/ink_role.dart';
import 'package:inklink/models/portfolio_item.dart';
import 'package:inklink/models/travel_intent.dart';

class InkProfile {
  final String id;
  final InkRole role;

  final String displayName;
  final String city;
  final String bio;
  final List<String> styles;

  final String avatarUrl; // placeholder
  final List<TravelIntent> travel;
  final List<PortfolioItem> portfolio;

  // Role extensions (keep optional for Phase 1)
  final String? shopName; // owners
  final bool? isHosting;  // owners
  final bool? isBooking;  // artists/clients
  final List<String>? lookingFor; // clients: "sleeve", "coverup", etc.

  const InkProfile({
    required this.id,
    required this.role,
    required this.displayName,
    required this.city,
    required this.bio,
    required this.styles,
    required this.avatarUrl,
    this.travel = const [],
    this.portfolio = const [],
    this.shopName,
    this.isHosting,
    this.isBooking,
    this.lookingFor,
  });

  bool matchesQuery(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return displayName.toLowerCase().contains(s) ||
        city.toLowerCase().contains(s) ||
        bio.toLowerCase().contains(s) ||
        styles.any((x) => x.toLowerCase().contains(s)) ||
        (shopName ?? '').toLowerCase().contains(s);
  }

  bool matchesCity(String? c) {
    final s = (c ?? '').trim().toLowerCase();
    if (s.isEmpty) return true;
    return city.toLowerCase().contains(s) ||
        travel.any((t) => t.city.toLowerCase().contains(s));
  }

  bool matchesStyles(Set<String> selected) {
    if (selected.isEmpty) return true;
    final mine = styles.map((e) => e.toLowerCase()).toSet();
    return selected.any((s) => mine.contains(s.toLowerCase()));
  }
}
