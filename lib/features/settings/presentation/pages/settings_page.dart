import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../timer/presentation/bloc/timer_bloc.dart';
import '../../../timer/presentation/bloc/timer_event.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          children: [
            Text('Settings', style: AppTheme.pixelText(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Shape the pace to fit your day.', style: AppTheme.pixelText(size: 15, color: AppTheme.textSecondary)),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'DURATIONS', trailing: 'minutes'),
            const SizedBox(height: 12),
            _DurationTile(label: 'Focus', value: state.focusMinutes, type: 'focus'),
            _DurationTile(label: 'Short break', value: state.shortBreakMinutes, type: 'short'),
            _DurationTile(label: 'Long break', value: state.longBreakMinutes, type: 'long'),
            const SizedBox(height: 22),
            const _SectionHeader(title: 'FEEDBACK'),
            const SizedBox(height: 12),
            _ToggleTile(
              label: 'Sound effects',
              icon: Icons.music_note_outlined,
              value: state.soundEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().setSound(value);
                context.read<TimerBloc>().add(
                      TimerSoundEffectsChanged(value),
                    );
              },
            ),
            _ToggleTile(
              label: 'Notification sound',
              icon: Icons.notifications_active_outlined,
              value: state.notificationSoundEnabled,
              onChanged: (value) {
                context.read<SettingsCubit>().setNotificationSound(value);
                context.read<TimerBloc>().add(
                      TimerNotificationSoundChanged(value),
                    );
              },
            ),
            _ToggleTile(label: 'Haptic feedback', icon: Icons.vibration_outlined, value: state.hapticsEnabled, onChanged: context.read<SettingsCubit>().setHaptics),
            const SizedBox(height: 22),
            const _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 12),
            Row(children: ['system', 'light', 'dark'].map((mode) {
              final active = state.themeMode == mode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: OutlinedButton(
                    onPressed: () => context.read<SettingsCubit>().setTheme(mode),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: active ? AppTheme.focusAccent : Colors.transparent,
                      foregroundColor: active ? AppTheme.blockShadow : AppTheme.textSecondary,
                      side: BorderSide(color: active ? AppTheme.focusAccent : AppTheme.blockShadow, width: 2),
                      shape: const BeveledRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(mode.toUpperCase(), style: AppTheme.pixelText(size: 11, color: active ? AppTheme.blockShadow : AppTheme.textSecondary, weight: FontWeight.w700)),
                  ),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({required this.label, required this.value, required this.type});

  final String label;
  final int value;
  final String type;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final timer = context.read<TimerBloc>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.block(),
      child: Row(
        children: [
          Text(label, style: AppTheme.pixelText(size: 15, weight: FontWeight.w600)),
          const Spacer(),
          IconButton(onPressed: value > 1 ? () async { await cubit.setDuration(type, value - 1); timer.add(TimerSettingsRefreshed()); } : null, icon: const Icon(Icons.remove), color: AppTheme.textSecondary),
          SizedBox(width: 42, child: Center(child: Text('$value', style: AppTheme.timerText(size: 20)))),
          IconButton(onPressed: () async { await cubit.setDuration(type, value + 1); timer.add(TimerSettingsRefreshed()); }, icon: const Icon(Icons.add), color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({required this.label, required this.icon, required this.value, required this.onChanged});

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: AppTheme.block(),
        child: Row(children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 13),
          Text(label, style: AppTheme.pixelText(size: 15, weight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: Duration.zero,
              width: 56,
              height: 28,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: value ? AppTheme.focusAccent : Colors.transparent, border: Border.all(color: value ? AppTheme.focusAccent : AppTheme.blockShadow, width: 2)),
              child: Align(alignment: value ? Alignment.centerRight : Alignment.centerLeft, child: Container(width: 16, height: 16, color: value ? AppTheme.blockShadow : AppTheme.textSecondary)),
            ),
          ),
        ]),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing = ''});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
          Text(trailing, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      );
}
