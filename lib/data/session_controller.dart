import 'package:flutter/foundation.dart';

import '../models/ink_profile.dart';
import '../models/ink_role.dart';
import '../repositories/profile_repository.dart';

class SessionController extends ChangeNotifier {
  final ProfileRepository profileRepo;

  SessionController({required this.profileRepo});

  InkProfile? me;

  Future<void> loadMe({String? id}) async {
    // simple + safe: pull a profile if id is given, otherwise do nothing
    if (id == null || id.trim().isEmpty) return;
    me = profileRepo.getById(id.trim());
    notifyListeners();
  }

  // role helpers
  bool get isClient => me?.role == InkRole.client;
  bool get isOwner => me?.role == InkRole.owner;
  bool get isArtist => me?.role == InkRole.artist;

  InkRole get role => me?.role ?? InkRole.client;
}
