import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/session_type.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_dots.dart';
import '../widgets/session_label.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<TimerBloc, TimerState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SessionLabel(type: state.type),
                    const SizedBox(height: 24),
                    CountdownRing(
                      progress: state.remainingSeconds / state.totalSeconds,
                      color: state.type == SessionType.focus
                          ? AppTheme.focusAccent
                          : state.type == SessionType.shortBreak
                              ? AppTheme.shortBreakAccent
                              : AppTheme.longBreakAccent,
                      time: _formatTime(state.remainingSeconds),
                    ),
                    const SizedBox(height: 28),
                    ControlButtons(
                      isRunning: state.isRunning,
                      onReset: () => context.read<TimerBloc>().add(TimerReset()),
                      onToggle: () => context.read<TimerBloc>().add(
                        state.isRunning ? TimerPaused() : TimerStarted(),
                      ),
                      onSkip: () => context.read<TimerBloc>().add(TimerSkipped()),
                    ),
                    const SizedBox(height: 20),
                    SessionDots(completed: state.completedFocusSessions),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }
}
