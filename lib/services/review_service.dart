import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  ReviewService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchArtistReviews(String artistId) {
    return _db
        .collection('reviews')
        .where('artistId', isEqualTo: artistId)
        .where('moderationStatus', isEqualTo: 'live')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}