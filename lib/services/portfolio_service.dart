import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_item.dart';

class PortfolioService {
  final _db = FirebaseFirestore.instance;

  Stream<List<PortfolioItem>> streamPortfolio(String artistId) {
    return _db
        .collection('portfolio')
        .where('artistId', isEqualTo: artistId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PortfolioItem(
                  id: d.id,
                  artistId: d['artistId'],
                  imageUrl: d['imageUrl'],
                  title: d['title'] ?? '',
                  caption: d['caption'] ?? '',
                  style: d['style'],
                  placement: d['placement'],
                  healed: d['healed'] ?? false,
                  coverUp: d['coverUp'] ?? false,
                ))
            .toList());
  }

  Future<void> savePortfolioItems(
      String artistId, List<PortfolioItem> items) async {
    final batch = _db.batch();

    for (final item in items) {
      final ref = _db.collection('portfolio').doc(item.id);
      batch.set(ref, item.toMap());
    }

    await batch.commit();
  }
}