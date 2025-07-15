import 'package:flutter/foundation.dart';
import 'package:keepprogressapp/services/user_session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../db/session_dao.dart';

class DataManager {
  static const _ttlMinutes = 10;
  static const _keyLastSessionSync = 'last_session_sync';

  static Future<List<Session>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastSyncStr = prefs.getString(_keyLastSessionSync);

    bool shouldFetch = true;
    if (lastSyncStr != null) {
      final lastSync = DateTime.tryParse(lastSyncStr);
      if (lastSync != null && now.difference(lastSync).inMinutes < _ttlMinutes) {
        shouldFetch = false;
      }
    }

    if (shouldFetch) {
      final userId = await UserSessionManager.getUserId();
      if (userId != null) {
        try {
          final sessionsFromApi = await ApiService.fetchSessions(userId);
          await SessionDao.insertAll(sessionsFromApi);
          await prefs.setString(_keyLastSessionSync, now.toIso8601String());
        } catch (e) {
          debugPrint("Erreur fetch API → fallback local : $e");
        }
      }
    }

    return await SessionDao.getAll();
  }

  static Future<void> addSession(Session session) async {
    final userId = await UserSessionManager.getUserId();
    if (userId == null) return;

    final success = await ApiService.addSession(userId, session);
    if (success) {
      await _refreshSessionsFromApi();
    }
  }

  static Future<void> deleteSession(int sessionId) async {
    final success = await ApiService.deleteSession(sessionId);
    if (success) {
      await _refreshSessionsFromApi();
    }
  }

  static Future<void> _refreshSessionsFromApi() async {
    final userId = await UserSessionManager.getUserId();
    if (userId == null) return;

    try {
      final sessions = await ApiService.fetchSessions(userId);
      await SessionDao.insertAll(sessions);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSessionSync, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint("Erreur sync après modif : $e");
    }
  }
}
