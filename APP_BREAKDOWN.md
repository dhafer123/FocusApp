# Focus App Breakdown

## Overview

Focus is a Flutter Pomodoro timer application with a dark Material 3 interface. It is organized by feature and uses Bloc/Cubit for state management, repository abstractions for persistence, and `go_router` for navigation.

## Technology Stack

- Flutter and Dart
- Material 3 UI
- `flutter_bloc` for Bloc and Cubit state management
- `equatable` for value-based state comparison
- `go_router` for routed navigation
- `shared_preferences` for local persistence
- `google_fonts` for application typography

## Application Structure

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── timer/
    │   ├── data/
    │   │   └── repositories/
    │   │       └── settings_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── session_type.dart
    │   │   │   └── timer_settings.dart
    │   │   └── repositories/
    │   │       └── settings_repository.dart
    │   │   └── presentation/
    │   │       ├── bloc/
    │   │       │   ├── timer_bloc.dart
    │   │       │   ├── timer_event.dart
    │   │       │   └── timer_state.dart
    │   │       ├── pages/
    │   │       │   └── timer_page.dart
    │   │       └── widgets/
    │   │           ├── control_buttons.dart
    │   │           ├── countdown_ring.dart
    │   │           ├── session_dots.dart
    │   │           └── session_label.dart
    │   ├── settings/
    │   │   └── presentation/
    │   │       ├── bloc/
    │   │       │   └── settings_cubit.dart
    │   │       └── pages/
    │   │           └── settings_page.dart
    │   └── stats/
    │       ├── data/
    │       │   └── repositories/
    │       │       └── session_history_repository_impl.dart
    │       ├── domain/
    │       │   ├── entities/
    │       │   │   └── focus_session_record.dart
    │       │   └── repositories/
    │       │       └── session_history_repository.dart
    │       └── presentation/
    │           ├── bloc/
    │           │   └── stats_cubit.dart
    │           └── pages/
    │               └── stats_page.dart
```

## App Bootstrap

### `main.dart`

Starts the application with `FocusApp`.

### `app.dart`

Creates the application-level dependency graph:

- Registers the settings repository.
- Registers the session history repository.
- Creates `TimerBloc`.
- Creates `SettingsCubit`.
- Creates `StatsCubit`.
- Applies the Material theme.
- Starts the `go_router` navigation tree.

## Navigation

The application uses a `StatefulShellRoute.indexedStack` with three persistent navigation branches:

| Route | Screen | Purpose |
|---|---|---|
| `/` | Timer | Run focus and break sessions |
| `/stats` | Stats | Review session history and progress |
| `/settings` | Settings | Configure durations and preferences |

The bottom navigation bar lets the user switch between these screens without losing each branch's navigation state.

## Timer Feature

### Timer States

The timer supports three session types:

- Focus
- Short break
- Long break

Each timer state contains:

- Current session type
- Remaining seconds
- Total seconds
- Whether the timer is running
- Number of completed focus sessions in the current cycle

### Timer Controls

The timer screen provides:

- Start
- Pause
- Reset
- Skip
- Circular countdown progress indicator
- Current session label
- Four-session progress dots

### Session Flow

1. The application starts with a focus session.
2. Starting the timer begins a one-second periodic ticker.
3. Each tick decreases the remaining time by one second.
4. When the timer reaches zero, the focus session is recorded locally.
5. A completed focus session advances to a short break.
6. Every fourth completed focus session advances to a long break.
7. Break sessions advance back to focus when completed or skipped.
8. The next session is prepared in a paused state.

### Timer Safety

Timer transitions await asynchronous session-history writes before emitting the next state. This prevents Bloc's `emit was called after an event handler completed` assertion.

## Settings Feature

The Settings screen currently provides:

### Durations

- Focus duration
- Short break duration
- Long break duration
- Decrease and increase controls
- Minimum duration is one minute

Duration values are saved through `SettingsRepository` and `SharedPreferences`. Duration updates also refresh the timer's repository-backed configuration.

### Feedback Preferences

- Completion sound toggle
- Haptic feedback toggle

These preferences are saved locally, but the actual sound and haptic effects are not implemented yet.

### Appearance

- System
- Light
- Dark

The selected value is saved locally, but the application currently always uses the configured dark theme. Runtime theme switching is not implemented yet.

## Stats Feature

The Stats screen currently provides:

- Total recorded sessions
- Seventy-day activity heatmap
- Current streak
- Longest streak
- Today's focus minutes
- Progress toward a 100-minute daily goal
- Tooltip text for individual heatmap days

Stats are calculated from locally stored `FocusSessionRecord` objects.

## Persistence

### Settings

Settings are stored with `SharedPreferences` using separate keys for:

- Focus minutes
- Short break minutes
- Long break minutes
- Sound enabled
- Haptics enabled
- Theme mode

### Session History

Completed focus sessions are stored as JSON strings in a `SharedPreferences` string list. Each record contains:

- Completion date
- Focus-session duration in minutes

## Theme and Visual Design

The app uses a dark blue background with accent colors for session types:

- Focus: teal
- Short break: green
- Long break: amber

The shared theme defines:

- Background colors
- Accent colors
- Primary and secondary text colors
- Navigation bar styling
- Google Fonts typography

## Tests and Validation

The project currently has a widget test that verifies:

- `FocusApp` can be created.
- The timer screen renders.
- The Focus label is present.
- The initial `25:00` timer is visible.

The latest validation commands pass:

```text
flutter analyze
flutter test
```

## Working Features

- Routed navigation between the three main screens
- Pomodoro countdown
- Start, pause, reset, and skip controls
- Automatic focus and break transitions
- Four-session long-break cycle
- Local session-history persistence
- Local timer-settings persistence
- Duration controls
- Session heatmap
- Current and longest streak calculations
- Daily focus progress
- Dark application theme

## Missing or Incomplete Features

- Completion sound playback
- Haptic feedback behavior
- Runtime light/dark/system theme switching
- Immediate stats refresh after a session is recorded
- Resetting the active countdown immediately when a duration is changed
- Auto-starting the next focus or break session
- Dedicated unit tests for timer transitions
- Dedicated tests for settings persistence
- Dedicated tests for stats calculations
- Recovery from malformed saved session-history JSON
- More complete responsive-layout testing on small screens

## Suggested Next Work

1. Add sound and haptic services behind small interfaces.
2. Make `FocusApp` react to `SettingsCubit.themeMode` and provide light/dark themes.
3. Refresh `StatsCubit` after `TimerBloc` records a completed session.
4. Add Bloc tests for timer transitions, skips, resets, and persistence.
5. Add repository tests for settings and session history.
6. Handle invalid or corrupted locally stored history gracefully.
7. Add an optional auto-start preference for the next session.
