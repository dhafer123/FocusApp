import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../timer/domain/repositories/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.soundEnabled = true,
    this.notificationSoundEnabled = true,
    this.hapticsEnabled = true,
    this.themeMode = 'system',
  });

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final bool soundEnabled;
  final bool notificationSoundEnabled;
  final bool hapticsEnabled;
  final String themeMode;

  SettingsState copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    bool? soundEnabled,
    bool? notificationSoundEnabled,
    bool? hapticsEnabled,
    String? themeMode,
  }) {
    return SettingsState(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
        notificationSoundEnabled:
          notificationSoundEnabled ?? this.notificationSoundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [focusMinutes, shortBreakMinutes, longBreakMinutes, soundEnabled, notificationSoundEnabled, hapticsEnabled, themeMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.repository) : super(const SettingsState()) {
    load();
  }

  final SettingsRepository repository;

  Future<void> load() async {
    emit(state.copyWith(
      focusMinutes: await repository.getFocusMinutes(),
      shortBreakMinutes: await repository.getShortBreakMinutes(),
      longBreakMinutes: await repository.getLongBreakMinutes(),
      soundEnabled: await repository.getSoundEnabled(),
        notificationSoundEnabled:
          await repository.getNotificationSoundEnabled(),
      hapticsEnabled: await repository.getHapticsEnabled(),
      themeMode: await repository.getThemeMode(),
    ));
  }

  Future<void> setDuration(String type, int minutes) async {
    if (type == 'focus') await repository.setFocusMinutes(minutes);
    if (type == 'short') await repository.setShortBreakMinutes(minutes);
    if (type == 'long') await repository.setLongBreakMinutes(minutes);
    emit(state.copyWith(
      focusMinutes: type == 'focus' ? minutes : null,
      shortBreakMinutes: type == 'short' ? minutes : null,
      longBreakMinutes: type == 'long' ? minutes : null,
    ));
  }

  Future<void> setSound(bool value) async {
    await repository.setSoundEnabled(value);
    emit(state.copyWith(soundEnabled: value));
  }

  Future<void> setHaptics(bool value) async {
    await repository.setHapticsEnabled(value);
    emit(state.copyWith(hapticsEnabled: value));
  }

  Future<void> setNotificationSound(bool value) async {
    await repository.setNotificationSoundEnabled(value);
    emit(state.copyWith(notificationSoundEnabled: value));
  }

  Future<void> setTheme(String value) async {
    await repository.setThemeMode(value);
    emit(state.copyWith(themeMode: value));
  }
}