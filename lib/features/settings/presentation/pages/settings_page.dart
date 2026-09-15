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
            const Text('Settings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Shape the pace to fit your day.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'DURATIONS', trailing: 'minutes'),
            const SizedBox(height: 12),
            _DurationTile(label: 'Focus', value: state.focusMinutes, type: 'focus'),
            _DurationTile(label: 'Short break', value: state.shortBreakMinutes, type: 'short'),
            _DurationTile(label: 'Long break', value: state.longBreakMinutes, type: 'long'),
            const SizedBox(height: 22),
            const _SectionHeader(title: 'FEEDBACK'),
            const SizedBox(height: 12),
            _ToggleTile(label: 'Completion sound', icon: Icons.volume_up_outlined, value: state.soundEnabled, onChanged: context.read<SettingsCubit>().setSound),
            _ToggleTile(label: 'Haptic feedback', icon: Icons.vibration_outlined, value: state.hapticsEnabled, onChanged: context.read<SettingsCubit>().setHaptics),
            const SizedBox(height: 22),
            const _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(14)),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('System')),
                  ButtonSegment(value: 'light', label: Text('Light')),
                  ButtonSegment(value: 'dark', label: Text('Dark')),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (selection) => context.read<SettingsCubit>().setTheme(selection.first),
                showSelectedIcon: false,
              ),
            ),
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
      decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(onPressed: value > 1 ? () async { await cubit.setDuration(type, value - 1); timer.add(TimerSettingsRefreshed()); } : null, icon: const Icon(Icons.remove), color: AppTheme.textSecondary),
          SizedBox(width: 42, child: Center(child: Text('$value', style: const TextStyle(fontSize: 20, color: AppTheme.focusAccent, fontWeight: FontWeight.w600)))),
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
        decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 13),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.focusAccent),
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
