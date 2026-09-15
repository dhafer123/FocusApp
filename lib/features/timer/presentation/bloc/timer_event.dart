import 'package:equatable/equatable.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class TimerStarted extends TimerEvent {}
class TimerPaused extends TimerEvent {}
class TimerReset extends TimerEvent {}
class TimerSkipped extends TimerEvent {}
class TimerTicked extends TimerEvent {}
class TimerSettingsLoaded extends TimerEvent {
  const TimerSettingsLoaded({
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
  });

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  @override
  List<Object?> get props => [focusMinutes, shortBreakMinutes, longBreakMinutes];
}

class TimerSettingsRefreshed extends TimerEvent {}
