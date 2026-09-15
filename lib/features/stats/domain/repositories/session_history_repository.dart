import '../entities/focus_session_record.dart';

abstract class SessionHistoryRepository {
  Future<List<FocusSessionRecord>> load();
  Future<void> record(FocusSessionRecord session);
}
