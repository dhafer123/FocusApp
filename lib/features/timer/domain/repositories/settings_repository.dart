abstract class SettingsRepository {
  Future<int> getFocusMinutes();
  Future<int> getShortBreakMinutes();
  Future<int> getLongBreakMinutes();
  Future<void> setFocusMinutes(int minutes);
  Future<void> setShortBreakMinutes(int minutes);
  Future<void> setLongBreakMinutes(int minutes);
  Future<bool> getSoundEnabled();
  Future<bool> getHapticsEnabled();
  Future<void> setSoundEnabled(bool enabled);
  Future<void> setHapticsEnabled(bool enabled);
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
}
