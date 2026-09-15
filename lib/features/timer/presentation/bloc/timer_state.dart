import 'package:equatable/equatable.dart';

import '../../domain/entities/session_type.dart';

class TimerState extends Equatable {
  const TimerState({
    this.type = SessionType.focus,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.isRunning = false,
    this.completedFocusSessions = 0,
  });

  final SessionType type;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final int completedFocusSessions;

  TimerState copyWith({
    SessionType? type,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    int? completedFocusSessions,
  }) {
    return TimerState(
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      completedFocusSessions: completedFocusSessions ?? this.completedFocusSessions,
    );
  }

  @override
  List<Object> get props => [type, remainingSeconds, totalSeconds, isRunning, completedFocusSessions];
}
