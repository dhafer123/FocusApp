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
import 'features/timer/presentation/widgets/startup_splash.dart';

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
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) => MaterialApp.router(
              title: 'Whisker Work',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.theme,
              themeMode: switch (settings.themeMode) {
                'light' => ThemeMode.light,
                'dark' => ThemeMode.dark,
                _ => ThemeMode.system,
              },
              routerConfig: AppRouter.router,
              builder: (context, child) => StartupSplash(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
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
    final colors = AppTheme.colors(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: colors.background,
            systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: colors.backgroundRaised,
              border: Border(
                top: BorderSide(color: colors.blockShadow, width: 2),
              ),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final active = navigationShell.currentIndex == index;
                final labels = ['TIME', 'STATS', 'SET'];
                final navigationTextColor =
                  Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : active
                      ? colors.blockShadow
                      : colors.textSecondary;
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
                          ? colors.focusAccent
                            : Colors.transparent,
                        foregroundColor: active
                          ? navigationTextColor
                          : navigationTextColor,
                        side: BorderSide(
                          color: active
                              ? colors.focusAccent
                              : colors.blockShadow,
                          width: 2,
                        ),
                        overlayColor: colors.focusAccent.withValues(alpha: 0.12),
                        shape: const BeveledRectangleBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        labels[index],
                        style: AppTheme.pixelText(
                          size: 12,
                            color: navigationTextColor,
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
