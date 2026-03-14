import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftStore {
  // One key for all drafts, but we filter by role inside the payload.
  static const String _key = 'ink_draft_v3';

  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Force role to exist so we can filter safely
    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    final fixed = Map<String, dynamic>.from(data);
    fixed['role'] = role; // can be '' but should not be null

    await prefs.setString(_key, jsonEncode(fixed));
  }

  /// Load the last saved draft.
  /// If [role] is provided, only returns it if the stored draft matches.
  static Future<Map<String, dynamic>?> load({String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;

    final map = Map<String, dynamic>.from(decoded);

    if (role != null && role.trim().isNotEmpty) {
      final want = role.trim().toLowerCase();
      final got = (map['role'] ?? '').toString().trim().toLowerCase();
      if (got != want) return null;
    }

    return map;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
