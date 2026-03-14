class PortfolioItem {
  final String id;
  final String artistId;
  final String imageUrl;
  final String title;
  final String caption;
  final String? style;
  final String? placement;
  final bool healed;
  final bool coverUp;

  PortfolioItem({
    required this.id,
    required this.artistId,
    required this.imageUrl,
    required this.title,
    required this.caption,
    this.style,
    this.placement,
    required this.healed,
    required this.coverUp,
  });

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'imageUrl': imageUrl,
      'title': title,
      'caption': caption,
      'style': style,
      'placement': placement,
      'healed': healed,
      'coverUp': coverUp,
      'createdAt': DateTime.now(),
    };
  }
}