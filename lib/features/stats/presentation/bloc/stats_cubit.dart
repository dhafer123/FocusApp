import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/focus_session_record.dart';
import '../../domain/repositories/session_history_repository.dart';

class StatsState extends Equatable {
  const StatsState({this.sessions = const [], this.loading = true});

  final List<FocusSessionRecord> sessions;
  final bool loading;

  StatsState copyWith({List<FocusSessionRecord>? sessions, bool? loading}) {
    return StatsState(sessions: sessions ?? this.sessions, loading: loading ?? this.loading);
  }

  @override
  List<Object> get props => [sessions, loading];
}

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this.repository) : super(const StatsState()) {
    load();
  }

  final SessionHistoryRepository repository;

  Future<void> load() async => emit(state.copyWith(sessions: await repository.load(), loading: false));

  int get todayMinutes => state.sessions.where((session) => _sameDay(session.date, DateTime.now())).fold(0, (sum, session) => sum + session.durationMinutes);

  int countOn(DateTime day) => state.sessions.where((session) => _sameDay(session.date, day)).length;

  int get currentStreak {
    final today = _day(DateTime.now());
    var cursor = state.sessions.any((session) => _sameDay(session.date, today)) ? today : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (state.sessions.any((session) => _sameDay(session.date, cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    final days = state.sessions.map((session) => _day(session.date)).toSet().toList()..sort();
    var longest = 0;
    var current = 0;
    for (var index = 0; index < days.length; index++) {
      current = index > 0 && days[index].difference(days[index - 1]).inDays == 1 ? current + 1 : 1;
      if (current > longest) longest = current;
    }
    return longest;
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
  bool _sameDay(DateTime first, DateTime second) => _day(first) == _day(second);
}