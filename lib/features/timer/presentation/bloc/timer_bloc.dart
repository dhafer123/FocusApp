import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/notifications/timer_notification_service.dart';
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
    on<TimerAppResumed>(_onAppResumed);
    on<TimerSoundEffectsChanged>(_onSoundEffectsChanged);
    on<TimerNotificationSoundChanged>(_onNotificationSoundChanged);
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _notificationPlayer = AudioPlayer();
  final Random _random = Random();
  String? _loadedTrack;
  int _audioRequest = 0;
  DateTime? _endTime;
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
    _endTime = DateTime.now().add(Duration(seconds: state.remainingSeconds));
    unawaited(_scheduleNotification());
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked());
    });
    emit(state.copyWith(isRunning: true));
    unawaited(_startSoundtrack(++_audioRequest));
  }

  Future<void> _onPaused(TimerPaused event, Emitter<TimerState> emit) async {
    _ticker?.cancel();
    _ticker = null;
    emit(state.copyWith(isRunning: false));
    ++_audioRequest;
    _endTime = null;
    unawaited(TimerNotificationService.instance.cancel());
    unawaited(_audioPlayer.pause());
  }

  Future<void> _onReset(TimerReset event, Emitter<TimerState> emit) async {
    final duration = _durationFor(state.type);
    _ticker?.cancel();
    _ticker = null;
    ++_audioRequest;
    _endTime = null;
    unawaited(TimerNotificationService.instance.cancel());
    unawaited(_audioPlayer.stop());
    _loadedTrack = null;
    emit(state.copyWith(
      isRunning: false,
      remainingSeconds: duration,
      totalSeconds: duration,
    ));
  }

  Future<void> _onSkipped(TimerSkipped event, Emitter<TimerState> emit) async {
    await _advanceTimer(emit, playCompletionSound: false);
  }

  Future<void> _onTicked(TimerTicked event, Emitter<TimerState> emit) async {
    if (_endTime != null) {
      final secondsLeft = _endTime!.difference(DateTime.now()).inSeconds;
      if (secondsLeft <= 0) {
        await _advanceTimer(emit);
        return;
      }
      if (secondsLeft < state.remainingSeconds) {
        emit(state.copyWith(remainingSeconds: secondsLeft));
        return;
      }
    }

    if (state.remainingSeconds <= 1) {
      await _advanceTimer(emit);
      return;
    }

    emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
  }

  Future<void> _onAppResumed(
    TimerAppResumed event,
    Emitter<TimerState> emit,
  ) async {
    if (!state.isRunning || _endTime == null) return;
    final secondsLeft = _endTime!.difference(DateTime.now()).inSeconds;
    if (secondsLeft <= 0) {
      await _advanceTimer(emit);
      return;
    }
    emit(state.copyWith(remainingSeconds: secondsLeft));
  }

  Future<void> _onSoundEffectsChanged(
    TimerSoundEffectsChanged event,
    Emitter<TimerState> emit,
  ) async {
    ++_audioRequest;
    if (!event.enabled) {
      _loadedTrack = null;
      await _audioPlayer.stop();
      return;
    }
    if (state.isRunning) {
      unawaited(
        _startSoundtrack(_audioRequest, enabled: event.enabled),
      );
    }
  }

  Future<void> _onNotificationSoundChanged(
    TimerNotificationSoundChanged event,
    Emitter<TimerState> emit,
  ) async {
    if (state.isRunning && _endTime != null) {
      unawaited(_scheduleNotification());
    }
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

  Future<void> _advanceTimer(
    Emitter<TimerState> emit, {
    bool playCompletionSound = true,
  }) async {
    ++_audioRequest;
    unawaited(_audioPlayer.stop());
    _loadedTrack = null;
    _endTime = null;
    unawaited(TimerNotificationService.instance.cancel());
    if (playCompletionSound) {
      unawaited(_playCompletionSound());
    }

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
      await _autoStartNextSession();
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
    await _autoStartNextSession();
  }

  Future<void> _autoStartNextSession() async {
    if (await settingsRepository.getAutoStartEnabled()) {
      add(TimerStarted());
    }
  }

  Future<void> _startSoundtrack(int request, {bool? enabled}) async {
    if (!(enabled ?? await settingsRepository.getSoundEnabled())) return;
    if (_loadedTrack != null) {
      if (request == _audioRequest && state.isRunning) {
        await _audioPlayer.play();
      }
      return;
    }

    const tracks = [
      'assets/soundeffects/C418 - Wet Hands - Minecraft Volume Alpha.mp3',
      'assets/soundeffects/C418 - Moog City - Minecraft Volume Alpha.mp3',
      'assets/soundeffects/C418 - Haggstrom - Minecraft Volume Alpha.mp3',
      'assets/soundeffects/C418  - Sweden - Minecraft Volume Alpha.mp3',
    ];
    final track = tracks[_random.nextInt(tracks.length)];
    try {
      await _audioPlayer.setAsset(track);
      await _audioPlayer.setLoopMode(LoopMode.one);
      if (request != _audioRequest || !state.isRunning) {
        await _audioPlayer.stop();
        return;
      }
      _loadedTrack = track;
      await _audioPlayer.play();
    } catch (_) {
      // Timer operation should remain available if audio cannot load.
    }
  }

  Future<void> _scheduleNotification() async {
    final soundEnabled =
        await settingsRepository.getNotificationSoundEnabled();
    if (_endTime != null && state.isRunning) {
      await TimerNotificationService.instance.schedule(
        _endTime!,
        soundEnabled: soundEnabled,
      );
    }
  }

  Future<void> _playCompletionSound() async {
    if (!await settingsRepository.getNotificationSoundEnabled()) return;
    try {
      await _notificationPlayer.setAsset(
        'assets/soundeffects/notification.mp3',
      );
      await _notificationPlayer.play();
    } catch (_) {
      // Completion notification remains available if in-app playback fails.
    }
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await _audioPlayer.dispose();
    await _notificationPlayer.dispose();
    return super.close();
  }
}
