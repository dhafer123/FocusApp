import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

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
      bottomNavigationBar: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: AppTheme.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundRaised,
              border: Border(
                top: BorderSide(color: AppTheme.blockShadow, width: 2),
              ),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final active = navigationShell.currentIndex == index;
                final labels = ['TIME', 'STATS', 'SET'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        if (index == 1) {
                          context.read<StatsCubit>().load();
                        }
                        navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == navigationShell.currentIndex,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: active
                            ? AppTheme.focusAccent
                            : Colors.transparent,
                        foregroundColor: active
                            ? AppTheme.blockShadow
                            : AppTheme.textSecondary,
                        side: BorderSide(
                          color: active
                              ? AppTheme.focusAccent
                              : AppTheme.blockShadow,
                          width: 2,
                        ),
                        shape: const BeveledRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        labels[index],
                        style: AppTheme.pixelText(
                          size: 12,
                          color: active
                              ? AppTheme.blockShadow
                              : AppTheme.textSecondary,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
