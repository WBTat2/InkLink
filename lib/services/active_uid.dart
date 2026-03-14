// lib/services/active_uid.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../config/demo_mode.dart';

String activeUidOrDemo() {
  if (kDemoMode) return kDemoUid;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('No user signed in (Auth UID is missing)');
  }
  return user.uid;
}
