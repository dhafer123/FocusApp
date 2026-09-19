import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/session_type.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../widgets/campfire_scene.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_dots.dart';
import '../widgets/session_label.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CampfireScene(),
          Container(color: colors.background.withValues(alpha: 0.55)),
          SafeArea(
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
                            color: colors.textSecondary,
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
                        style: AppTheme.timerText(color: colors.textPrimary),
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
                    SessionDots(completed: state.completedFocusSessions),
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

class _MotivationQuote extends StatelessWidget {
  const _MotivationQuote({required this.progress, required this.accent});

  static const quotes = [
    'Start where you are.',
    'One quiet minute at a time.',
    'Small steps still move you forward.',
    'Keep going. You are building momentum.',
    'Your attention is a place you can return to.',
    'The work is becoming lighter.',
    'Stay with it. You are closer than you think.',
    'Finish this moment with care.',
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
