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
          final colors = AppTheme.colors(context);
          final cubit = context.read<StatsCubit>();
          final today = cubit.todayMinutes;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            children: [
              Text('Stats', style: AppTheme.pixelText(size: 32, color: colors.textPrimary, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Your rhythm, over time.', style: AppTheme.pixelText(size: 15, color: colors.textSecondary)),
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
                decoration: AppTheme.block(palette: colors),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Focus minutes', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),
                  _SegmentedProgress(value: (today / 100).clamp(0, 1)),
                  const SizedBox(height: 12),
                  Text(today == 0 ? 'Complete a session to start your record.' : 'Your focus is adding up.', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
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
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.block(palette: colors),
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
                  color: count == 0 ? colors.background : count == 1 ? colors.backgroundRaised : count == 2 ? colors.focusAccent.withValues(alpha: 0.65) : colors.focusAccent,
                  border: Border.all(color: colors.blockShadow, width: 1),
                ),
              ),
            );
          }),
        ),
        );
      }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.unit, required this.label});

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.block(palette: AppTheme.colors(context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTheme.timerText(size: 32, color: AppTheme.colors(context).textPrimary)),
          Text(unit, style: TextStyle(color: AppTheme.colors(context).textSecondary, fontSize: 12)),
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
          Text(title, style: TextStyle(color: AppTheme.colors(context).textSecondary, fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
          Text(trailing, style: TextStyle(color: AppTheme.colors(context).textSecondary, fontSize: 12)),
        ],
      );
}

class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final filled = (value.clamp(0, 1) * 10).floor();
    return Row(
      children: List.generate(10, (index) => Expanded(
        child: Container(
          height: 14,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: index < filled ? AppTheme.colors(context).focusAccent : AppTheme.colors(context).background,
            border: Border.all(color: AppTheme.colors(context).blockShadow, width: 1),
          ),
        ),
      )),
    );
  }
}
