# Focus App Features

Focus is a Flutter Pomodoro timer designed around short, repeatable focus sessions, local progress tracking, pixel-art visuals, and optional audio feedback.

## Main Navigation

The app has three persistent screens:

- **TIME**: Run focus and break sessions.
- **STATS**: Review completed focus sessions and progress.
- **SET**: Configure durations, feedback, and appearance.

Navigation uses a persistent indexed stack, so switching tabs does not reset each screen's navigation state.

## Timer

The timer supports three session types:

- Focus
- Short break
- Long break

### Timer controls

- **Start** begins the current session.
- **Pause** pauses the countdown and soundtrack.
- **Reset** returns the current session to its configured duration.
- **Skip** advances to the next session without recording the current focus session.
- The timer displays the current session type and remaining time.
- The cycle indicator shows progress through the four-focus-session cycle.

### Session flow

1. The app starts with a focus session.
2. A completed focus session is recorded locally.
3. Focus completion advances to a short break.
4. Every fourth completed focus session advances to a long break.
5. A completed or skipped break advances to a focus session.
6. New sessions begin paused.

Focus session records are only created when a focus timer reaches zero. Skipped focus sessions are not recorded.

## Background Timer Support

The timer uses an absolute end time instead of relying only on an in-memory periodic timer.

This allows it to:

- Catch up when the app returns from the background.
- Recalculate the remaining time after the phone is locked.
- Complete the session after the app has been suspended, provided the operating system allows the scheduled work.

The operating system controls behavior after a force-stop, reboot, or powered-off device.

## Sound Effects

The app includes optional background soundtrack playback using local MP3 files from `assets/soundeffects/`.

Features:

- A random soundtrack is selected when a session starts.
- The selected track loops while the session is running.
- Pausing pauses the soundtrack.
- Resetting, skipping, or completing a session stops the soundtrack.
- Sound effects can be enabled or disabled immediately from the SET screen.
- Toggling sound effects does not require resetting the timer.

## Completion Notifications

When a running session reaches its end:

- A local operating-system notification is scheduled.
- The notification can use the bundled `notification.mp3` sound.
- The notification sound can be enabled or disabled independently from soundtrack playback.
- Pending notifications are canceled when the timer is paused, reset, skipped, or completed.
- Android notification permission is requested when needed.
- iOS notification permissions are requested when needed.

## Statistics

The STATS screen displays locally calculated progress, including:

- Total completed focus sessions.
- A 70-day activity heatmap.
- Current consecutive-day streak.
- Longest consecutive-day streak.
- Today's completed focus minutes.
- Progress toward a 100-minute daily goal.
- Tooltips showing the date and session count for heatmap cells.

The Stats tab reloads saved session history when opened, so recently completed sessions appear without restarting the app.

## Settings

### Timer durations

Users can configure:

- Focus duration.
- Short break duration.
- Long break duration.

Duration values are persisted locally, with a minimum of one minute.

The plus and minus controls support:

- Single tap for one increment or decrement.
- Press and hold for automatic repeated changes.
- A short initial delay before repeat starts.
- A faster repeat interval while held.

### Feedback settings

- **Sound effects** controls soundtrack playback immediately.
- **Notification sound** controls the sound played when a timer completes.
- **Auto-start next session** automatically starts the next focus or break session after completion or skip.

Sound preferences persist between app launches.

### Appearance settings

The app supports:

- **SYSTEM**: Follows the device light or dark setting.
- **LIGHT**: Uses the muted light palette.
- **DARK**: Uses the pixel-art dark palette.

Theme selection applies immediately and is persisted locally.

## Visual Design

- Pixel-art background scene using `assets/background.jpg`.
- Pixel-art cat sprite animation using `assets/Idle.png`.
- The sprite sheet contains ten 32x32 frames and loops horizontally.
- Pixel rendering uses disabled image filtering to keep sprites sharp.
- App logo uses `assets/logo.png` in the header.
- The same logo is generated as the Android and iOS launcher icon.
- Pixel-style typography uses Google Fonts.
- Timer controls and navigation use beveled, pixel-inspired shapes.
- Light mode uses a separate palette and a darker scene overlay so text remains readable over the artwork.

## Persistence

`SharedPreferences` stores:

- Focus duration.
- Short break duration.
- Long break duration.
- Sound-effects preference.
- Notification-sound preference.
- Haptic-feedback preference.
- Auto-start preference.
- Theme mode.
- Completed focus-session history.

Session records are stored as JSON strings containing the completion date and duration in minutes.

## Platform Integration

### Android

- Local notifications.
- Android 13 notification permission declaration.
- Custom notification sound packaged as an Android raw resource.
- Core library desugaring enabled for notification support.
- Generated launcher icons.

### iOS

- Local notifications.
- Background audio capability declaration.
- Generated AppIcon assets.

## Project Architecture

- **Bloc/Cubit** manages timer and settings state.
- **Repositories** abstract local settings and session-history persistence.
- **go_router** manages the three-tab navigation shell.
- **just_audio** handles soundtrack and foreground notification audio playback.
- **flutter_local_notifications** schedules completion alerts.
- **timezone** supports scheduled notification timing.
- **flutter_launcher_icons** generates platform launcher icons.

## Assets

- `assets/background.jpg`: Main scene background.
- `assets/Idle.png`: Ten-frame cat idle sprite sheet.
- `assets/logo.png`: Header logo and launcher icon source.
- `assets/soundeffects/`: Focus soundtrack MP3 files.
- `assets/soundeffects/notification.mp3`: Completion notification sound.

## Validation

The project is validated with:

```text
flutter analyze
flutter test test/widget_test.dart
flutter build apk --debug
```

The widget test verifies that the app boots, the timer screen renders, and the initial timer is visible.
