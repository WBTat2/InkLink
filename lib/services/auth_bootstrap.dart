import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBootstrap {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// 1) Sign in if exists, otherwise create the user.
  static Future<UserCredential> signInOrCreate({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      rethrow;
    }
  }

  /// 2) Ensure Firestore docs exist for this uid.
  static Future<void> ensureUserDocs({required String role}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user.");

    final uid = user.uid;
    final email = user.email ?? "";

    final now = FieldValue.serverTimestamp();

    final userRef = _db.collection('users').doc(uid);
    final profileRef = _db.collection('profiles').doc(uid);
    final artistRef = _db.collection('artist_profiles').doc(uid);

    // users/{uid}
    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      await userRef.set({
        'email': email,
        'role': role, // "artist" | "client" | "owner"
        'profileComplete': false,
        'createdAt': now,
      });
    } else {
      // keep role current (optional)
      await userRef.update({
        'role': role,
      });
    }

    // profiles/{uid}
    final profileSnap = await profileRef.get();
    if (!profileSnap.exists) {
      await profileRef.set({
        'displayName': '',
        'city': '',
        'bio': '',
        'instagram': '',
        'notificationEmail': email,
        'updatedAt': now,
      });
    }

    // artist_profiles/{uid}
    if (role == 'artist') {
      final artistSnap = await artistRef.get();
      if (!artistSnap.exists) {
        await artistRef.set({
          'bookingEnabled': true,
          'takesGuestSpots': true,
          'styles': <String>[],
          'travelingTo': <String>[],
          'createdAt': now,
        });
      }
    }
  }
}
