import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/stats/data/repositories/session_history_repository_impl.dart';
import 'features/stats/domain/repositories/session_history_repository.dart';
import 'features/stats/presentation/bloc/stats_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/timer/data/repositories/settings_repository_impl.dart';
import 'features/timer/domain/repositories/settings_repository.dart';
import 'features/timer/presentation/bloc/timer_bloc.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (_) => SettingsRepositoryImpl(),
        ),
        RepositoryProvider<SessionHistoryRepository>(
          create: (_) => SessionHistoryRepositoryImpl(),
        ),
      ],
      child: BlocProvider(
        create: (context) => TimerBloc(
          context.read<SettingsRepository>(),
          context.read<SessionHistoryRepository>(),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SettingsCubit(context.read<SettingsRepository>())),
            BlocProvider(create: (context) => StatsCubit(context.read<SessionHistoryRepository>())),
          ],
          child: MaterialApp.router(
            title: 'Focus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timelapse_outlined), selectedIcon: Icon(Icons.timelapse), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}
