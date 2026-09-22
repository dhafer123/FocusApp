# Focus

A pixel-art Pomodoro timer for quiet, repeatable focus sessions.

Focus combines a simple timer workflow with local progress tracking, optional
soundtracks, completion notifications, and a small pixel-art companion scene.

## Features

### Timer

- Focus, short-break, and long-break sessions.
- Start, pause, reset, and skip controls.
- Four-session cycle tracking.
- Optional automatic start for the next session.
- Countdown recovery after the app is backgrounded or the screen is locked.
- The timer records a focus session only when it reaches zero.

### Audio and notifications

- Random looping soundtrack selected when a session starts.
- Sound effects can be enabled or disabled immediately.
- Separate notification-sound preference.
- Completion notification while the app is backgrounded.
- Custom completion and cycle-success sounds.
- A themed celebration popup after four completed focus sessions.

### Statistics

- Completed focus-session count.
- Seventy-day activity heatmap.
- Current and longest streaks.
- Today's completed focus minutes.
- Progress toward a 100-minute daily goal.
- Session history persisted locally on the device.

### Settings

- Focus, short-break, and long-break durations.
- Tap or hold the plus/minus controls for automatic repetition.
- Sound effects and notification sound controls.
- Auto-start next session toggle.
- System, light, and dark appearance modes.
- Settings persist between launches.

## Visuals

- Pixel-art room background.
- Ten-frame animated cat sprite.
- Pixel-style typography and beveled controls.
- App logo used in the interface and as the Android/iOS launcher icon.
- Light and dark palettes with scene-aware timer contrast.

## Tech Stack

- Flutter and Dart
- `flutter_bloc` for state management
- `go_router` for persistent tab navigation
- `shared_preferences` for local settings and session history
- `just_audio` for soundtrack and foreground sound playback
- `flutter_local_notifications` for scheduled completion alerts
- `timezone` for notification scheduling
- `google_fonts` for pixel-style typography
- `flutter_launcher_icons` for platform launcher icons

## Project Structure

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── notifications/
│   ├── router/
│   └── theme/
└── features/
	├── timer/
	├── stats/
	└── settings/
```

The project follows a feature-oriented structure. Timer and settings behavior
are managed with Bloc/Cubit classes, while repositories isolate local storage.

## Requirements

- Flutter SDK compatible with Dart `^3.10.8`
- Android Studio or Xcode for mobile builds
- A connected Android/iOS device or emulator

## Run Locally

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run static analysis and tests:

```bash
flutter analyze
flutter test
```

Build a debug Android APK:

```bash
flutter build apk --debug
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

For a distributable build:

```bash
flutter build apk --release
```

Release builds should use a production signing key before distribution.

## Assets

```text
assets/
├── background.jpg
├── Idle.png
├── logo.png
└── soundeffects/
	├── notification.mp3
	├── success-sound-effect_zPBDmIhP.mp3
	└── soundtrack files
```

`Idle.png` is a 320x32 horizontal sprite sheet containing ten 32x32 frames.

## Platform Notes

- Android requests notification permission when required.
- Android packages the custom notification sound as a raw resource.
- iOS declares background audio support for soundtrack playback.
- The operating system may restrict work after a force-stop, reboot, or power-off.

## Documentation

See [FEATURES.md](FEATURES.md) for the complete feature inventory and behavior
reference.
