import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _focusKey = 'focus_minutes';
  static const _shortBreakKey = 'short_break_minutes';
  static const _longBreakKey = 'long_break_minutes';
  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _themeKey = 'theme_mode';

  @override
  Future<int> getFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_focusKey) ?? 25;
  }

  @override
  Future<int> getShortBreakMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shortBreakKey) ?? 5;
  }

  @override
  Future<int> getLongBreakMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longBreakKey) ?? 15;
  }

  @override
  Future<void> setFocusMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusKey, minutes);
  }

  @override
  Future<void> setShortBreakMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shortBreakKey, minutes);
  }

  @override
  Future<void> setLongBreakMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_longBreakKey, minutes);
  }

  @override
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  @override
  Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsKey) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  @override
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }
}
