class ArtistDraft {
  final String displayName;
  final String instagram;
  final String city;
  final String state;
  final String bio;
  final List<String> styles;

  // Placeholder: later you can store portfolio image metadata here too.
  final List<Map<String, String>> portfolioItems;

  const ArtistDraft({
    required this.displayName,
    required this.instagram,
    required this.city,
    required this.state,
    required this.bio,
    required this.styles,
    required this.portfolioItems,
  });

  factory ArtistDraft.empty() => const ArtistDraft(
        displayName: '',
        instagram: '',
        city: '',
        state: '',
        bio: '',
        styles: [],
        portfolioItems: [],
      );

  ArtistDraft copyWith({
    String? displayName,
    String? instagram,
    String? city,
    String? state,
    String? bio,
    List<String>? styles,
    List<Map<String, String>>? portfolioItems,
  }) {
    return ArtistDraft(
      displayName: displayName ?? this.displayName,
      instagram: instagram ?? this.instagram,
      city: city ?? this.city,
      state: state ?? this.state,
      bio: bio ?? this.bio,
      styles: styles ?? this.styles,
      portfolioItems: portfolioItems ?? this.portfolioItems,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'instagram': instagram,
        'city': city,
        'state': state,
        'bio': bio,
        'styles': styles,
        'portfolioItems': portfolioItems,
      };

  static ArtistDraft fromMap(Map<String, dynamic> map) {
    final stylesList = (map['styles'] as List?)?.cast<String>() ?? <String>[];
    final rawItems = (map['portfolioItems'] as List?) ?? [];
    final items = rawItems.whereType<Map>().map((e) {
      return {
        'id': (e['id'] ?? '').toString(),
        'label': (e['label'] ?? '').toString(),
      };
    }).where((m) => (m['id'] ?? '').isNotEmpty).toList();

    return ArtistDraft(
      displayName: (map['displayName'] ?? '').toString(),
      instagram: (map['instagram'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      styles: stylesList,
      portfolioItems: items,
    );
  }
}
