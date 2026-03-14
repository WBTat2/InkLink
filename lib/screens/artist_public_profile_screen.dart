import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/artist_profile_service.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import '../models/portfolio_item.dart';
import '../services/portfolio_service.dart';

class ArtistPublicProfileScreen extends StatelessWidget {
  const ArtistPublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = ArtistProfileService();
    final reviewService = ReviewService();
    final portfolioService = PortfolioService();

    return Scaffold(
      appBar: AppBar(title: const Text('Artist Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profileService.watchMyArtistProfile(),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = profileSnapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('No profile yet'));
          }

          final artistId =
              (data['uid'] ?? ArtistProfileService.demoUid).toString();
          final displayName = (data['displayName'] ?? '').toString();
          final city = (data['city'] ?? '').toString();
          final state = (data['state'] ?? '').toString();
          final bio = (data['bio'] ?? '').toString();
          final styles = List<String>.from(data['styles'] ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _profileHeader(
                context,
                displayName: displayName,
                city: city,
                state: state,
                bio: bio,
                styles: styles,
              ),

              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: reviewService.watchArtistReviews(artistId),
                builder: (context, reviewSnapshot) {
                  final reviewDocs = reviewSnapshot.data?.docs ?? [];

                  double avgRating = 0;
                  if (reviewDocs.isNotEmpty) {
                    final total = reviewDocs.fold<double>(0, (sum, doc) {
                      final rating = doc.data()['rating'];
                      if (rating is num) return sum + rating.toDouble();
                      return sum;
                    });
                    avgRating = total / reviewDocs.length;
                  }

                  return Column(
                    children: [
                      _reviewSummaryCard(
                        context,
                        avgRating: avgRating,
                        reviewCount: reviewDocs.length,
                      ),
                      const SizedBox(height: 16),
                      if (reviewSnapshot.connectionState ==
                          ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (reviewDocs.isEmpty)
                        _emptyReviewsCard()
                      else
                        ...reviewDocs.take(3).map((doc) {
                          final r = doc.data();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _reviewCard(r),
                          );
                        }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              StreamBuilder<List<PortfolioItem>>(
                stream: portfolioService.streamPortfolio(artistId),
                builder: (context, portfolioSnapshot) {
                  if (portfolioSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (portfolioSnapshot.hasError) {
                    return _simpleCard(
                      child: Text(
                        'Error loading portfolio: ${portfolioSnapshot.error}',
                      ),
                    );
                  }

                  final items = portfolioSnapshot.data ?? [];

                  if (items.isEmpty) {
                    return _simpleCard(
                      child: const Text(
                        'No portfolio work added yet.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return _portfolioPreview(context, items);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(
    BuildContext context, {
    required String displayName,
    required String city,
    required String state,
    required String bio,
    required List<String> styles,
  }) {
    return _simpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName.isEmpty ? 'Artist' : displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (city.isNotEmpty || state.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${city.isEmpty ? '' : city}${city.isNotEmpty && state.isNotEmpty ? ', ' : ''}${state.isEmpty ? '' : state}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(bio),
          ],
          if (styles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: styles.map((style) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white10,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    style,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reviewSummaryCard(
    BuildContext context, {
    required double avgRating,
    required int reviewCount,
  }) {
    final ratingText =
        reviewCount == 0 ? 'No rating yet' : avgRating.toStringAsFixed(1);

    return _simpleCard(
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ratingText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  reviewCount == 0
                      ? 'No reviews yet'
                      : '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyReviewsCard() {
    return _simpleCard(
      child: const Text(
        'No reviews yet.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final rating = review['rating'];
    final ratingValue = rating is num ? rating.toDouble() : 0.0;

    final text = (review['text'] ?? '').toString();
    final verified = review['verified'] == true;
    final reviewerRole = (review['reviewerRole'] ?? '').toString();
    final createdAt = review['createdAt'];
    final categories = review['categories'];

    String createdText = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      createdText = '${dt.month}/${dt.day}/${dt.year}';
    }

    return _simpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < ratingValue.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                ratingValue == 0 ? 'No rating' : ratingValue.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (verified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.green.withOpacity(0.15),
                    border: Border.all(color: Colors.green.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (reviewerRole.isNotEmpty || createdText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${reviewerRole.isEmpty ? '' : reviewerRole}${reviewerRole.isNotEmpty && createdText.isNotEmpty ? ' • ' : ''}${createdText.isEmpty ? '' : createdText}',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
          if (text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(text),
          ],
          if (categories is Map && categories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.entries.map<Widget>((entry) {
                final label = entry.key.toString();
                final value = entry.value.toString();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white10,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    '$label: $value',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _portfolioPreview(BuildContext context, List<PortfolioItem> items) {
    return _simpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length > 4 ? 4 : items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => _showPortfolioDetail(context, item),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.title.trim().isNotEmpty)
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (item.style != null &&
                                item.style!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.style!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (items.length > 4) ...[
            const SizedBox(height: 12),
            Text(
              '+ ${items.length - 4} more piece${items.length - 4 == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }

  void _showPortfolioDetail(BuildContext context, PortfolioItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 340,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 340,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (item.title.trim().isNotEmpty)
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (item.caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.caption,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                if ((item.style ?? '').trim().isNotEmpty ||
                    (item.placement ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((item.style ?? '').trim().isNotEmpty)
                        _chip(item.style!),
                      if ((item.placement ?? '').trim().isNotEmpty)
                        _chip(item.placement!),
                      if (item.healed) _chip('Healed'),
                      if (item.coverUp) _chip('Cover-up'),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white10,
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _simpleCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}