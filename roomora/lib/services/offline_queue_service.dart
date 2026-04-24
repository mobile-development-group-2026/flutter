import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueueService {
  static const String _queueKey = 'pending_tasks';
  static const String _listingDraftKey = 'listing_draft';
  static const String _profileDraftKey = 'profile_draft';

  Future<void> addTask(String type, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_queueKey) ?? [];
    final newTask = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
    };
    existing.add(json.encode(newTask));
    await prefs.setStringList(_queueKey, existing);
  }

  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson = prefs.getStringList(_queueKey) ?? [];
    return tasksJson.map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>).toList();
  }

  Future<void> removeTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasks = prefs.getStringList(_queueKey) ?? [];
    final filtered = tasks.where((taskJson) {
      final task = json.decode(taskJson) as Map<String, dynamic>;
      return task['id'] != id;
    }).toList();
    await prefs.setStringList(_queueKey, filtered);
  }

  Future<void> saveListingDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_listingDraftKey, json.encode(draft));
  }

  Future<Map<String, dynamic>?> loadListingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftJson = prefs.getString(_listingDraftKey);
    if (draftJson != null) {
      return json.decode(draftJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearListingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_listingDraftKey);
  }

  Future<void> saveProfileDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileDraftKey, json.encode(draft));
  }

  Future<Map<String, dynamic>?> loadProfileDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftJson = prefs.getString(_profileDraftKey);
    if (draftJson != null) {
      return json.decode(draftJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearProfileDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileDraftKey);
  }
}