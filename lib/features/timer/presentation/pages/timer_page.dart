import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../domain/entities/session_type.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../widgets/campfire_scene.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_label.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  final AudioPlayer _celebrationPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _celebrationPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<TimerBloc>().add(TimerAppResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final sceneForeground = isLightMode
        ? const Color(0xFFF4EDE4)
        : colors.textPrimary;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CampfireScene(),
          Container(
            color: isLightMode
                ? Colors.black.withValues(alpha: 0.32)
                : colors.background.withValues(alpha: 0.55),
          ),
          SafeArea(
            child: BlocListener<TimerBloc, TimerState>(
              listenWhen: (previous, current) =>
                  current.completedFocusSessions >
                      previous.completedFocusSessions &&
                  current.completedFocusSessions % 4 == 0,
              listener: (context, state) {
                _showCycleCelebration(context);
              },
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                final accent = state.type == SessionType.focus
                    ? colors.focusAccent
                    : state.type == SessionType.shortBreak
                    ? colors.shortBreakAccent
                    : colors.longBreakAccent;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WHISKER WORK',
                          style: AppTheme.pixelText(
                            size: 14,
                            color: sceneForeground,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(3),
                          decoration: AppTheme.block(palette: colors),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 110),
                    SessionLabel(type: state.type),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        _formatTime(state.remainingSeconds),
                        style: AppTheme.timerText(color: sceneForeground),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ControlButtons(
                      isRunning: state.isRunning,
                      accent: accent,
                      onReset: () =>
                          context.read<TimerBloc>().add(TimerReset()),
                      onToggle: () => context.read<TimerBloc>().add(
                        state.isRunning ? TimerPaused() : TimerStarted(),
                      ),
                      onSkip: () =>
                          context.read<TimerBloc>().add(TimerSkipped()),
                    ),
                    const SizedBox(height: 24),
                    _CycleProgress(completed: state.completedFocusSessions),
                    const SizedBox(height: 20),
                    _MotivationQuote(
                      progress: 1 - state.remainingSeconds / state.totalSeconds,
                      accent: accent,
                    ),
                  ],
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCycleCelebration(BuildContext context) async {
    final colors = AppTheme.colors(context);
    final settings = context.read<SettingsCubit>().state;
    if (settings.notificationSoundEnabled) {
      try {
        await _celebrationPlayer.setAsset(
          'assets/soundeffects/success-sound-effect_zPBDmIhP.mp3',
        );
        await _celebrationPlayer.play();
      } catch (_) {
        // The celebration dialog remains available if audio cannot load.
      }
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.backgroundRaised,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: colors.focusAccent, width: 2),
        ),
        title: Text(
          'Cycle complete!',
          style: AppTheme.pixelText(
            size: 22,
            color: colors.textPrimary,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Four focus sessions finished. Take a well-earned long break.',
          style: AppTheme.pixelText(size: 14, color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(foregroundColor: colors.focusAccent),
            child: Text(
              'CONTINUE',
              style: AppTheme.pixelText(
                size: 12,
                color: colors.focusAccent,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }
}

class _CycleProgress extends StatelessWidget {
  const _CycleProgress({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final cyclePosition = completed % 4 + 1;
    return Center(
      child: Text(
        'CYCLE $cyclePosition / 4',
        style: AppTheme.pixelText(
          size: 11,
          color: colors.textSecondary,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MotivationQuote extends StatelessWidget {
  const _MotivationQuote({required this.progress, required this.accent});

  static const quotes = [
  'You’ve got this.',
  'One step at a time.',
  'Keep moving forward.',
  'You’re doing great.',
  'Progress takes time.',
  'Stay with it.',
  'Keep the momentum.',
  'You’re making progress.',
];

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final quoteIndex = (progress.clamp(0, 0.9999) * quotes.length).floor();
    return SizedBox(
      height: 64,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Text(
          quotes[quoteIndex],
          key: ValueKey(quoteIndex),
          textAlign: TextAlign.center,
          style: AppTheme.pixelText(size: 20, color: accent),
        ),
      ),
    );
  }
}
