import 'package:inklink/models/ink_profile.dart';
import 'package:inklink/models/ink_role.dart';
import 'package:inklink/models/portfolio_item.dart';
import 'package:inklink/models/travel_intent.dart';

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

final List<InkProfile> seedProfiles = [
  InkProfile(
    id: 'a1',
    role: InkRole.artist,
    displayName: 'Raven Black',
    city: 'Dallas, TX',
    bio: 'Black & grey realism. Travel-ready. Clean work only.',
    styles: const ['Realism', 'Black & Grey', 'Portrait'],
    avatarUrl: 'https://picsum.photos/seed/a1/200',
    isBooking: true,
    travel: [
      TravelIntent(city: 'Denver, CO', start: _d(2026, 5, 10), end: _d(2026, 5, 20), note: 'Guest spot'),
      TravelIntent(city: 'Phoenix, AZ', start: _d(2026, 6, 3), end: _d(2026, 6, 8), note: 'Booking'),
    ],
    portfolio: List.generate(
      6,
      (i) => PortfolioItem(
        id: 'a1p$i',
        title: 'Piece ${i + 1}',
        imageUrl: 'https://picsum.photos/seed/a1p$i/600/600',
        tags: const ['blackwork', 'realism'],
      ),
    ),
  ),
  InkProfile(
    id: 'a2',
    role: InkRole.artist,
    displayName: 'Kilo Lines',
    city: 'Chicago, IL',
    bio: 'Neo-trad + color. Big projects. No flakes.',
    styles: const ['Neo-Traditional', 'Color', 'Japanese'],
    avatarUrl: 'https://picsum.photos/seed/a2/200',
    isBooking: true,
    travel: [
      TravelIntent(city: 'Nashville, TN', start: _d(2026, 4, 12), end: _d(2026, 4, 16), note: 'Booking'),
    ],
    portfolio: List.generate(
      6,
      (i) => PortfolioItem(
        id: 'a2p$i',
        title: 'Flash ${i + 1}',
        imageUrl: 'https://picsum.photos/seed/a2p$i/600/600',
        tags: const ['color', 'bold'],
      ),
    ),
  ),
  InkProfile(
    id: 'o1',
    role: InkRole.owner,
    displayName: 'Maya Cruz',
    city: 'Denver, CO',
    bio: 'Owner. Curating guest spots for realism + fineline.',
    styles: const ['Realism', 'Fineline'],
    avatarUrl: 'https://picsum.photos/seed/o1/200',
    shopName: 'High Voltage Tattoo Co.',
    isHosting: true,
    travel: const [],
    portfolio: const [],
  ),
    InkProfile(
    id: 'c1',
    role: InkRole.client,
    displayName: 'Jordan K.',
    city: 'Austin, TX',
    bio: 'Serious client. Planning a full sleeve this year.',
    styles: const ['Black & Grey', 'Fineline'],
    avatarUrl: 'https://picsum.photos/seed/c1/200',
    lookingFor: const ['Sleeve', 'Coverup'],
    isBooking: true,
    travel: [
      TravelIntent(city: 'Denver, CO', start: _d(2026, 5, 14), end: _d(2026, 5, 18), note: 'Traveling'),
    ],
    portfolio: const [],
  ),
];
