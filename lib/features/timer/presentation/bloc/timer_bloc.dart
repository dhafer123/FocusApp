import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/session_type.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../stats/domain/entities/focus_session_record.dart';
import '../../../stats/domain/repositories/session_history_repository.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc(this.settingsRepository, this.sessionHistoryRepository)
      : super(const TimerState()) {
    on<TimerSettingsLoaded>(_onSettingsLoaded);
    on<TimerSettingsRefreshed>(_onSettingsRefreshed);
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerReset>(_onReset);
    on<TimerSkipped>(_onSkipped);
    on<TimerTicked>(_onTicked);
    Future.microtask(() async {
      add(TimerSettingsLoaded(
        focusMinutes: await settingsRepository.getFocusMinutes(),
        shortBreakMinutes: await settingsRepository.getShortBreakMinutes(),
        longBreakMinutes: await settingsRepository.getLongBreakMinutes(),
      ));
    });
  }

  final SettingsRepository settingsRepository;
  final SessionHistoryRepository sessionHistoryRepository;
  Timer? _ticker;
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;

  Future<void> _onSettingsLoaded(TimerSettingsLoaded event, Emitter<TimerState> emit) async {
    _focusMinutes = event.focusMinutes;
    _shortBreakMinutes = event.shortBreakMinutes;
    _longBreakMinutes = event.longBreakMinutes;
    final total = _focusMinutes * 60;
    emit(state.copyWith(
      remainingSeconds: total,
      totalSeconds: total,
    ));
  }

  Future<void> _onSettingsRefreshed(TimerSettingsRefreshed event, Emitter<TimerState> emit) async {
    add(TimerSettingsLoaded(
      focusMinutes: await settingsRepository.getFocusMinutes(),
      shortBreakMinutes: await settingsRepository.getShortBreakMinutes(),
      longBreakMinutes: await settingsRepository.getLongBreakMinutes(),
    ));
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked());
    });
    emit(state.copyWith(isRunning: true));
  }

  Future<void> _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    _ticker?.cancel();
    _ticker = null;
    emit(state.copyWith(isRunning: false));
  }

  Future<void> _onReset(TimerReset event, Emitter<TimerState> emit) async {
    final duration = _durationFor(state.type);
    _ticker?.cancel();
    _ticker = null;
    emit(state.copyWith(
      isRunning: false,
      remainingSeconds: duration,
      totalSeconds: duration,
    ));
  }

  Future<void> _onSkipped(TimerSkipped event, Emitter<TimerState> emit) async {
    await _advanceTimer(emit);
  }

  Future<void> _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    if (state.remainingSeconds <= 1) {
      await _advanceTimer(emit);
      return;
    }

    emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
  }

  int _durationFor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return _focusMinutes * 60;
      case SessionType.shortBreak:
        return _shortBreakMinutes * 60;
      case SessionType.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  Future<void> _advanceTimer(Emitter<TimerState> emit) async {
    if (state.type == SessionType.focus) {
      final completed = state.completedFocusSessions + 1;
      await sessionHistoryRepository.record(
        FocusSessionRecord(
          date: DateTime.now(),
          durationMinutes: _focusMinutes,
        ),
      );

      final nextType = completed % 4 == 0 ? SessionType.longBreak : SessionType.shortBreak;
      final duration = _durationFor(nextType);

      _ticker?.cancel();
      _ticker = null;

      emit(state.copyWith(
        type: nextType,
        remainingSeconds: duration,
        totalSeconds: duration,
        isRunning: false,
        completedFocusSessions: completed,
      ));
      return;
    }

    final duration = _durationFor(SessionType.focus);
    _ticker?.cancel();
    _ticker = null;

    emit(state.copyWith(
      type: SessionType.focus,
      remainingSeconds: duration,
      totalSeconds: duration,
      isRunning: false,
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
