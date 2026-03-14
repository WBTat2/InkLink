import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistProfileService {
  ArtistProfileService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String demoUid = 'demo_artist';

  /// ✅ Real method your flow expects.
  /// Use [uid] when you have Auth; if not provided, falls back to demo.
  Future<void> upsertArtistProfile(
    Map<String, dynamic> draft, {
    String? uid,
  }) async {
    final id = (uid == null || uid.isEmpty) ? demoUid : uid;
    final now = FieldValue.serverTimestamp();

    await _db.collection('artist_profiles').doc(id).set({
      'uid': id,
      'role': 'artist',
      'displayName': draft['displayName'] ?? '',
      'city': draft['city'] ?? '',
      'state': draft['state'] ?? '',
      'bio': draft['bio'] ?? '',
      'styles': draft['styles'] ?? [],
      'socialLinks': draft['socialLinks'] ?? [],
      'profileImagePath': draft['profileImagePath'],
      'updatedAt': now,
      'createdAt': now,
    }, SetOptions(merge: true));

    await _db.collection('users').doc(id).set({
      'uid': id,
      'role': 'artist',
      'displayName': draft['displayName'] ?? '',
      'city': draft['city'] ?? '',
      'state': draft['state'] ?? '',
      'updatedAt': now,
      'createdAt': now,
    }, SetOptions(merge: true));
  }

  /// Backwards compatible demo method.
  Future<void> upsertDemoArtistProfile(Map<String, dynamic> draft) async {
    return upsertArtistProfile(draft, uid: demoUid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchMyArtistProfile({
    String? uid,
  }) {
    final id = (uid == null || uid.isEmpty) ? demoUid : uid;
    return _db.collection('artist_profiles').doc(id).snapshots();
  }
}