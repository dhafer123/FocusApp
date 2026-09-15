import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/stats_cubit.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          final cubit = context.read<StatsCubit>();
          final today = cubit.todayMinutes;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            children: [
              const Text('Stats', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Your rhythm, over time.', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 30),
              _SectionHeader(title: 'LAST 10 WEEKS', trailing: '${state.sessions.length} sessions'),
              const SizedBox(height: 14),
              _Heatmap(cubit: context.read<StatsCubit>()),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: _StatCard(value: '${cubit.currentStreak}', unit: 'days', label: 'Current streak')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(value: '${cubit.longestStreak}', unit: 'days', label: 'Longest streak')),
              ]),
              const SizedBox(height: 28),
              _SectionHeader(title: 'TODAY', trailing: '$today / 100 min'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Focus minutes', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: (today / 100).clamp(0, 1), minHeight: 10, backgroundColor: const Color(0xFF26364D), color: AppTheme.focusAccent),
                  ),
                  const SizedBox(height: 12),
                  Text(today == 0 ? 'Complete a session to start your record.' : 'Your focus is adding up.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.cubit});

  final StatsCubit cubit;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(18)),
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(70, (index) {
            final day = DateTime.now().subtract(Duration(days: 69 - index));
            final count = cubit.countOn(day);
            return Tooltip(
              message: '${day.month}/${day.day}: $count sessions',
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: count == 0 ? Colors.white.withValues(alpha: 0.06) : AppTheme.focusAccent.withValues(alpha: (0.18 + count * 0.16).clamp(0, 1)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.unit, required this.label});

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: AppTheme.focusAccent)),
          Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

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
