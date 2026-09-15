import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/focus_session_record.dart';
import '../../domain/repositories/session_history_repository.dart';

class SessionHistoryRepositoryImpl implements SessionHistoryRepository {
  static const _key = 'focus_session_history';

  @override
  Future<List<FocusSessionRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw
        .map((entry) => FocusSessionRecord.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> record(FocusSessionRecord session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await load();
    sessions.add(session);
    final serialized = sessions.map((value) => jsonEncode(value.toJson())).toList();
    await prefs.setStringList(_key, serialized);
  }
}
